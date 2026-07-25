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
  planning contracts complete; S01-S08 terminal. S04 binds Audit 0-pre/A1 to
  the registry-derived guard result, freezes the profile-aware audit-result and
  attempt contract, and preserves delivery verdict semantics. Current-session
  closeout evidence passes the 22-assertion contract selftest and 24-assertion
  persistent audit-path regression. S05 is Done: validate and finalize now
  re-resolve and bind certification to the one current audit attempt, planning
  promotion is status-only, and the focused cross-boundary regression passes
  48/48. S06 is Done: its behavior matrix, persistent regression, canonical
  framework validation, agnosticity, and change-boundary checks are green.
  S07 is Done: the registry-bound transition contract, planning/delivery
  vocabulary, audit attempt/resume semantics, exact-ceiling certification,
  canonical-source-first release guidance, installed provenance checks, and
  coherent rollback are published with current-session docs evidence. S08 is
  Done: version `7.20.0`, truthful release notes, manifest-last regeneration,
  hermetic install provenance, supported rollback, canonical release-check,
  and change-boundary checks are green. S09 installed-snapshot provenance,
  21-surface parity, integrity, doctor, and framework validation are green, but
  S09 is blocked: after its exact GuestHost baseline passed, a concurrent
  S10-shaped process changed Spec 151 `state.json` from `not_started` to
  `specs_hardened` with audit/validate promotion fields. This invocation did
  not start S10 and did not touch or revert the concurrent state. No commit,
  tag, push, published release, propagation, downstream upgrade, clean S09,
  overall fix, or bug closure claim is made
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
| S06 Matrix and persistent regression | `bubbles.test` | S05 | 12 scenarios, 24-mode matrix, done controls, regression runner | `framework-validate` | Done — 48/48 persistent regression, 56/56 resolver matrix, 22/22 audit-result contract, canonical validation, agnosticity, and boundary checks pass |
| S07 Documentation contract | `bubbles.docs` | S06 | Maintainer/operator docs and changelog | Docs/agnosticity validation | Done — docs contract, agnosticity, integrity, and boundary checks pass; manifest freshness routed to S08 |
| S08 Canonical release package | `bubbles.releases` with `bubbles.devops` for installer provenance | S07 | Version, derived registries, installer, release manifest | `release-check` | Done — v7.20.0, manifest-last regeneration, install/rollback provenance, final release-check, and boundary checks pass |
| S09 GuestHost supported upgrade | `bubbles.devops` | S08 | Supported upgrade, installed manifest/checksums, byte parity | Installed provenance parity | Blocked — installed snapshot passes; concurrent S10 mutation changed protected Spec 151 state |
| S10 GuestHost audit/transition | `bubbles.audit`, then `bubbles.validate` for certification only | S09 | Spec 151 audit evidence and exact planning transition | Real consumer audit at `specs_hardened` | Not Started |

The next eligible scope is S09. No later scope may start until every dependency
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

- **Status:** Done — executable matrix, persistent regression, canonical
  framework validation, agnosticity, and change-boundary verification are green
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

- [x] All 12 acceptance scenarios have behavior-level assertions through production paths. Evidence: [S06 persistent A-L production-path evidence](#bug-009-s06-persistent-a-l-production-path-evidence).
- [x] The complete 24-mode non-done audit inventory and audit-bearing done inventory have explicit, design-consistent outcomes with zero planning leakage. Evidence: [S06 registry-derived matrix evidence](#bug-009-s06-registry-derived-matrix-evidence).
- [x] Planning positives, done negatives, planning-gate negatives, metadata mismatches, alias compatibility, and audit output contracts all pass. Evidence: [S06 transition guard evidence](#bug-009-s06-transition-guard-evidence) and [S06 audit-result contract evidence](#bug-009-s06-audit-result-contract-evidence).
- [x] The regression fails on pre-fix source and passes on fixed source without an early return, generated success record, or fake delivery artifact. Evidence: [S01 terminal intentional RED evidence](#bug-009-s01-terminal-intentional-red-evidence), [S06 persistent A-L production-path evidence](#bug-009-s06-persistent-a-l-production-path-evidence), and [S06 regression integrity evidence](#bug-009-s06-regression-integrity-evidence).
- [x] `bash bubbles/scripts/cli.sh framework-validate` exits zero with full output. Evidence: [S06 canonical framework validation evidence](#bug-009-s06-canonical-framework-validation-evidence).
- [x] `bash bubbles/scripts/cli.sh agnosticity` exits zero with full output. Evidence: [S06 agnosticity evidence](#bug-009-s06-agnosticity-evidence).
- [x] No file outside the S06 change boundary changed. Evidence: [S06 change-boundary evidence](#bug-009-s06-change-boundary-evidence).

##### BUG-009 S06 Persistent A-L Production-Path Evidence

**Phase:** test
**Command:** `cd /Users/pkirsanov/Projects/bubbles && printf '%s\n' 'COMMAND: bash tests/regression/test_23_planning_audit_contract.sh' && bash tests/regression/test_23_planning_audit_contract.sh; exit_code=$?; printf 'EXIT_CODE=%s\n' "$exit_code"; exit "$exit_code"`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
PASS: fixture is honestly unimplemented
PASS: integrity adversary 'fake-test' is rejected
PASS: integrity adversary 'fake-evidence' is rejected
PASS: bypassing the production invocation is rejected
PASS: Audit 0-pre resolves the canonical transition guard path
PASS: Audit A1 consumes the profile-scoped state-transition guard verdict
PASS: direct and Audit 0-pre/A1 paths each executed the production guard
PASS: real Audit 0-pre result and persisted attempt pass the S04 contract lint
PASS: clean planning certification changes only both status mirrors to specs_hardened
PASS: stale audit digest is rejected against the real guard result
PASS: stale audit revision is rejected at certification
PASS: done-ceiling delivery path still strictly requires DoD, Done scopes, test files, and evidence
GREEN_REGRESSION_VERDICT=PLANNING_AUDIT_CONTRACT_SATISFIED
DIRECT_GUARD_EXIT=0
AUDIT_0_PRE_A1_EXIT=0
AUDIT_RESULT_LINT_EXIT=0
test_23_planning_audit_contract: 48 passed, 0 failed
EXIT_CODE=0
```

**Result:** PASS — the persistent A-L regression executes the real resolver,
guard, Audit 0-pre/A1, result lint, validate, and finalize contracts. All 48
behavior assertions pass, including the honest planning positive, metadata and
certification adversaries, and the unchanged done-ceiling delivery control.

##### BUG-009 S06 Registry-Derived Matrix Evidence

**Phase:** test
**Command:** `cd /Users/pkirsanov/Projects/bubbles && printf '%s\n' 'COMMAND: bash bubbles/scripts/transition-contract-resolver-selftest.sh' && bash bubbles/scripts/transition-contract-resolver-selftest.sh; exit_code=$?; printf 'EXIT_CODE=%s\n' "$exit_code"; exit "$exit_code"`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
PASS: source layout resolves byte-identical contracts
PASS: installed .github/bubbles layout resolves byte-identical contracts
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
EXIT_CODE=0
```

**Result:** PASS — effective registry resolution assigns the planning profile
to exactly two designed modes, keeps all 22 adjacent non-done audit modes
unsupported, and resolves all 27 audit-bearing done modes through explicit
delivery contracts without planning leakage.

##### BUG-009 S06 Transition Guard Evidence

**Phase:** test
**Command:** `cd /Users/pkirsanov/Projects/bubbles && printf '%s\n' 'COMMAND: bash bubbles/scripts/state-transition-guard-selftest.sh' && bash bubbles/scripts/state-transition-guard-selftest.sh; exit_code=$?; printf 'EXIT_CODE=%s\n' "$exit_code"; exit "$exit_code"`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
PASS: BUG-009 S03: honest product-to-planning packet passes via legacy one-argument invocation
PASS: BUG-009 S03: both designed planning modes share the same explicit profile contract
PASS: BUG-009 S03: mismatched target assertion blocks with guard exit 2
PASS: BUG-009 S03: stale digest assertion blocks with guard exit 2
PASS: BUG-009 S03: the honest incomplete packet fails under done-ceiling delivery semantics
PASS: BUG-009 S03: delivery Check 4 completion remains blocking
PASS: BUG-009 S03: delivery Check 5 all-Done remains blocking
PASS: BUG-009 S03: delivery Check 8 file existence remains blocking
PASS: BUG-009 S03: delivery Check 11 execution evidence remains blocking
PASS: BUG-009 S03: broken Gherkin-to-DoD fidelity fails planning guard
PASS: BUG-009 S03: G073 source-edit adversary blocks planning guard
PASS: BUG-009 S03: G087 linkage adversary blocks the real planning guard
PASS: BUG-009 S03: G091 chain adversary blocks the real planning guard
state-transition-guard selftest passed.
EXIT_CODE=0
```

**Result:** PASS — planning positives and planning-gate negatives remain active,
metadata mismatches fail loud, and the honest fixture receives no exemption
under done-ceiling delivery semantics.

##### BUG-009 S06 Audit-Result Contract Evidence

**Phase:** test
**Command:** `cd /Users/pkirsanov/Projects/bubbles && printf '%s\n' 'COMMAND: bash bubbles/scripts/audit-result-contract-lint-selftest.sh' && bash bubbles/scripts/audit-result-contract-lint-selftest.sh; exit_code=$?; printf 'EXIT_CODE=%s\n' "$exit_code"; exit "$exit_code"`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
PASS: planning clean view is exact and profile-bound
PASS: planning rework view names a concrete owner
PASS: delivery refusal preserves DO_NOT_SHIP semantics
PASS: metadata uncertainty is BLOCKED without fallback semantics
PASS: source-edit lockout is BLOCKED on G073
PASS: interruption leaves no current pointer or active verdict
PASS: rework supersedes prior result and preserves the finding one-to-one
PASS: planning shipment language is rejected
PASS: stale contract digest is rejected against guard provenance
PASS: stale target revision is rejected against guard provenance
PASS: multiple ACTIVE attempts are rejected
PASS: disappearing prior finding is rejected
PASS: canonical audit agent passes structural contract lint
PASS: Audit A1 wording is profile-scoped and registry-resolved
audit-result-contract-lint-selftest: 22 passed, 0 failed
EXIT_CODE=0
```

**Result:** PASS — all five result views, interruption/rework semantics,
metadata freshness, finding closure, and planning/delivery vocabulary remain
exact and profile-bound.

##### BUG-009 S06 Regression Integrity Evidence

**Phase:** test
**Command:** `cd /Users/pkirsanov/Projects/bubbles && printf '%s\n' 'COMMAND: bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_23_planning_audit_contract.sh' && bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_23_planning_audit_contract.sh; exit_code=$?; printf 'EXIT_CODE=%s\n' "$exit_code"; exit "$exit_code"`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
COMMAND: bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_23_planning_audit_contract.sh
============================================================
  BUBBLES REGRESSION QUALITY GUARD
  Repo: /Users/pkirsanov/Projects/bubbles
  Timestamp: 2026-07-11T19:56:19Z
  Bugfix mode: true
============================================================
Scanning tests/regression/test_23_planning_audit_contract.sh
Adversarial signal detected in tests/regression/test_23_planning_audit_contract.sh
============================================================
  REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
  Files scanned: 1
  Files with adversarial signals: 1
============================================================
EXIT_CODE=0
```

**Result:** PASS — the preserved S01 evidence records the exact pre-fix RED,
the current production-path regression is green, and the regression-quality
guard confirms an adversarial bugfix signal with no bailout or proxy-test
violation. The token-aware disabled-test scan also exited 0 with zero matches;
the broader unbounded `xit(` pattern was rejected as a false positive because
it matched an AWK `exit(` statement, not a test marker.

##### BUG-009 S06 Canonical Framework Validation Evidence

**Phase:** test
**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/cli.sh framework-validate`
**Exit Code:** 0
**Claim Source:** executed
**Output (final window of the full unfiltered terminal run):**

```text
PASS: Case 7: CHANGELOG.md historical exclusion (exit 0)
PASS: Case 8: docs/v6-mcp-design.md exclusion (exit 0)
PASS: Case 9: missing VERSION fails (exit 1)
PASS: Case 10: lapsed caught alongside a legit future deferral (exit 1)
PASS: Case 11: own selftest path is excluded (exit 0)

stale-deferral-lint-selftest: 11 pass, 0 fail
PASS: Stale-deferral lint selftest

==> Stale-deferral lint (live)
[stale-deferral-lint] OK — no lapsed forward-references (current VERSION 7.19.2)
PASS: Stale-deferral lint (live)

Framework validation passed.
```

**Result:** PASS — the exact canonical command from
`.specify/memory/agents.md` exited 0 after release-owned manifest
reconciliation. The full run included the registered resolver, audit-result,
transition-guard, persistent BUG-009 regression, release-manifest freshness,
release-manifest selftest, registry, shellcheck, and portability checks. No S06
repair was required.

##### BUG-009 S06 Agnosticity Evidence

**Phase:** test
**Command:** `cd /Users/pkirsanov/Projects/bubbles && printf '%s\n' 'COMMAND: bash bubbles/scripts/cli.sh agnosticity' 'PURPOSE: BUG-009 S06 final portability and agnosticity proof' 'REPOSITORY: /Users/pkirsanov/Projects/bubbles' 'PLATFORM: macOS' 'EXPECTED_SCOPE: portable framework surfaces' '--- AGNOSTICITY OUTPUT BEGIN ---' && bash bubbles/scripts/cli.sh agnosticity; exit_code=$?; printf '%s\n' '--- AGNOSTICITY OUTPUT END ---' "FILES_REPORTED=456" "AGNOSTICITY_EXIT_CODE=$exit_code" 'S06_AGNOSTICITY_CHECK=COMPLETE'; exit "$exit_code"`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
COMMAND: bash bubbles/scripts/cli.sh agnosticity
PURPOSE: BUG-009 S06 final portability and agnosticity proof
REPOSITORY: /Users/pkirsanov/Projects/bubbles
PLATFORM: macOS
EXPECTED_SCOPE: portable framework surfaces
--- AGNOSTICITY OUTPUT BEGIN ---
Scanning 456 portable file(s) for agnosticity drift
Portable Bubbles surfaces are project-agnostic and tool-agnostic
--- AGNOSTICITY OUTPUT END ---
FILES_REPORTED=456
AGNOSTICITY_EXIT_CODE=0
S06_AGNOSTICITY_CHECK=COMPLETE
```

**Result:** PASS — all 456 portable framework files pass the canonical
agnosticity check on macOS.

##### BUG-009 S06 Change-Boundary Evidence

**Phase:** test
**Command:** `cd /Users/pkirsanov/Projects/bubbles && printf '%s\n' 'COMMAND: shasum -c /tmp/bubbles-bug009-s06-unrelated.sha1 plus exact S06 delta assertion' && shasum -c /tmp/bubbles-bug009-s06-unrelated.sha1 && actual_delta="$(git diff HEAD --numstat -- bubbles/scripts/framework-validate.sh tests/regression/test_23_planning_audit_contract.sh)" && expected_delta=$'1\t0\tbubbles/scripts/framework-validate.sh\n167\t5\ttests/regression/test_23_planning_audit_contract.sh' && [[ "$actual_delta" == "$expected_delta" ]] && printf '%s\n' 'PASS: S06 executable deltas remain exactly 1/0 and 167/5' 'PASS: no unrelated baseline hash changed' 'FILES_HASH_VERIFIED=23' 'S06_UNEXPECTED_PATHS=0' 'EXIT_CODE=0'`
**Exit Code:** 0
**Claim Source:** executed
**Output (representative window from the complete 28-line comparison):**

```text
S06 mechanical unrelated-file preservation check
PASS: unchanged agents/bubbles.redteam.agent.md sha1=6cdaaac9620b591156e5fcfafc0ac6f6a18f9867
PASS: unchanged agents/bubbles.super.agent.md sha1=c1c46a79389b5a280e72c256e747c873982d710a
PASS: unchanged agents/bubbles.validate.agent.md sha1=7352808dc641f1e366b93d88cfc88a10f6d481ae
PASS: unchanged agents/bubbles_shared/agent-common.md sha1=a942ee689b843bcd9747aef27f8b2977e1f3fb79
PASS: unchanged agents/bubbles_shared/feature-templates.md sha1=b69e466a1fc1be10e63b744e1f582a7adb9e1cca
PASS: unchanged agents/bubbles_shared/scope-templates.md sha1=8060c09212e0db9e0ae6922fb91a4f91f747f282
PASS: unchanged agents/bubbles_shared/scope-workflow.md sha1=5b1e43648759ac1eec555e69e60ee134df57b8ac
PASS: unchanged agents/bubbles_shared/workflow-phase-engine.md sha1=fbcc305790751b1c376399461dc98bd3df270ac6
PASS: unchanged bubbles/release-manifest.json sha1=af546ecdceeb335ab548d4c66c16ec8fb0cd2bc5
PASS: unchanged bubbles/workflows.yaml sha1=8d7dea45baa2cd05563cec8ca4e4e74717b63cce
PASS: unchanged docs/CATALOG.md sha1=1dfa34f563ea7e8bd09ce88fe7da4912155d8437
PASS: unchanged bubbles/scripts/adversarial-aggregate-selftest.sh sha1=226ed99a5f1635b60842ea140e64ae39582fd6a7
PASS: unchanged bubbles/scripts/adversarial-aggregate.sh sha1=7098666908cfa6239e6519447d6e865c4b041c59
PASS: S06 executable deltas remain exactly 1/0 and 167/5
PASS: no unrelated baseline hash changed
FILES_HASH_VERIFIED=23
S06_UNEXPECTED_PATHS=0
EXIT_CODE=0
```

**Result:** PASS — every unrelated dirty or untracked file present before the
BUGS.md evidence edit retained its exact byte hash, including the release-owned
manifest and the three untracked IMP-020/eval files. The two S06 executable
deltas remain exactly one registration addition in `framework-validate.sh` and
167 additions/five deletions in `test_23`; all other listed S06 scripts remain
clean. No index mutation was performed by this invocation.

**S06 disposition:** terminal `completed_owned`. All seven S06 DoD items have
current-session execution evidence, no S06 finding remains unresolved, and S07
is now eligible. S07 remains Not Started; its required owner is `bubbles.docs`.

#### S07 — Documentation Contract

- **Status:** Done — documentation contract published and S07-owned checks pass
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

- [x] Managed docs describe the implemented registry/resolver/guard/audit/finalize contract with no contradictory legacy instruction. Evidence: [S07 documentation behavior contract evidence](#bug-009-s07-documentation-behavior-contract-evidence).
- [x] Planning maturity cannot be read as implemented, tested, merge-ready, releasable, deployable, delivered, or shipped. Evidence: [S07 planning-versus-delivery vocabulary evidence](#bug-009-s07-planning-versus-delivery-vocabulary-evidence).
- [x] Delivery anti-fabrication and rollback instructions remain explicit. Evidence: [S07 coherent rollback evidence](#bug-009-s07-coherent-rollback-evidence).
- [x] `CHANGELOG.md` claims only behavior proven by S06 and leaves downstream verification to S10 evidence. Evidence: [S07 changelog truth evidence](#bug-009-s07-changelog-truth-evidence).
- [x] Framework validation and agnosticity pass after docs changes. Evidence: [S07 validation and S08 manifest classification evidence](#bug-009-s07-validation-and-s08-manifest-classification-evidence). Agnosticity, the supported core framework tier, links, docs registry, governance index, and scoped diff checks pass; the full aggregate is nonzero only for S08-owned release-manifest freshness and selftest checks.
- [x] No file outside the S07 change boundary changed. Evidence: [S07 concurrent-change and boundary evidence](#bug-009-s07-concurrent-change-and-boundary-evidence).

##### BUG-009 S07 Documentation Behavior Contract Evidence

**Phase:** docs
**Command:**

```bash
cd /Users/pkirsanov/Projects/bubbles && fail_count=0; check_doc() { label="$1"; pattern="$2"; file="$3"; if grep -Fq -- "$pattern" "$file"; then printf 'PASS: %s\n' "$label"; else printf 'FAIL: %s\n' "$label"; fail_count=$((fail_count + 1)); fi; }; printf '%s\n' 'BUG-009 S07 documentation behavior contract' 'CHECK GROUP: registry and profile authority'; check_doc 'mode registry is documented as authority' '`bubbles/workflows/modes.yaml` is the authority' docs/guides/AGENT_MANUAL.md; check_doc 'exactly two planning modes are named' 'Only `product-to-planning` and `spec-scope-hardening` bind' docs/guides/AGENT_MANUAL.md; check_doc '22 adjacent non-done modes remain unsupported' 'All 22 adjacent non-done audit modes' docs/guides/AGENT_MANUAL.md; printf '%s\n' 'CHECK GROUP: resolver, guard, and applicability'; check_doc 'guard expectations are assertion-only' '`--expect-contract-digest` are equality assertions' docs/guides/AGENT_MANUAL.md; check_doc 'transition result v1 is documented' '`TRANSITION_GUARD_RESULT_V1`' docs/guides/CONTROL_PLANE_DESIGN.md; check_doc 'profile-specific check applicability is documented' 'Check 4 completion, Check 5 all-Done, Check 8' docs/guides/CONTROL_PLANE_DESIGN.md; printf '%s\n' 'CHECK GROUP: audit attempts and certification'; check_doc 'audit result v1 is documented' '`AUDIT_RESULT_V1`' docs/guides/AGENT_MANUAL.md; check_doc 'interruption leaves no reusable verdict' 'interruption therefore leaves no reusable active verdict' docs/guides/AGENT_MANUAL.md; check_doc 'resume phase is documented' '`resumeFromPhase`' docs/guides/AGENT_MANUAL.md; check_doc 'validate owns exact-ceiling mirrors' 'Validate alone may mirror top-level `status` and' docs/guides/AGENT_MANUAL.md; printf 'DOCUMENTATION_CONTRACT_FAILURES=%s\n' "$fail_count"; if [[ "$fail_count" -ne 0 ]]; then exit 1; fi; printf '%s\n' 'BUG-009 S07 documentation behavior contract: PASS'
```

**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
BUG-009 S07 documentation behavior contract
CHECK GROUP: registry and profile authority
PASS: mode registry is documented as authority
PASS: exactly two planning modes are named
PASS: 22 adjacent non-done modes remain unsupported
CHECK GROUP: resolver, guard, and applicability
PASS: guard expectations are assertion-only
PASS: transition result v1 is documented
PASS: profile-specific check applicability is documented
CHECK GROUP: audit attempts and certification
PASS: audit result v1 is documented
PASS: interruption leaves no reusable verdict
PASS: resume phase is documented
PASS: validate owns exact-ceiling mirrors
DOCUMENTATION_CONTRACT_FAILURES=0
BUG-009 S07 documentation behavior contract: PASS
```

**Result:** PASS — the detailed docs publish the implemented registry,
resolver, guard applicability, result-version, audit attempt/resume, and
validate-owned exact-ceiling contracts, including the 22-mode unsupported
boundary.

##### BUG-009 S07 Planning-Versus-Delivery Vocabulary Evidence

**Phase:** docs
**Command:**

```bash
cd /Users/pkirsanov/Projects/bubbles && fail_count=0; check_doc() { label="$1"; pattern="$2"; file="$3"; if grep -Fq -- "$pattern" "$file"; then printf 'PASS: %s\n' "$label"; else printf 'FAIL: %s\n' "$label"; fail_count=$((fail_count + 1)); fi; }; printf '%s\n' 'BUG-009 S07 planning-versus-delivery vocabulary' 'CHECK: planning terminal status'; check_doc 'planning stops at specs_hardened' 'both stop exactly at' README.md; check_doc 'planning delivery is NOT_EVALUATED' '`NOT_EVALUATED`' README.md; printf '%s\n' 'CHECK: forbidden delivery implications'; check_doc 'not implemented or tested' 'It does not mean implemented, tested' README.md; check_doc 'not merge-ready or releasable' 'merge-ready, releasable' README.md; check_doc 'not deployable, delivered, or shipped' 'deployable, delivered, or shipped' README.md; printf '%s\n' 'CHECK: vocabulary separation'; check_doc 'planning verdict is PLANNING_AUDIT_CLEAN' '`PLANNING_AUDIT_CLEAN`' docs/guides/AGENT_MANUAL.md; check_doc 'planning never emits SHIP_IT' 'It never emits `SHIP_IT`' docs/guides/AGENT_MANUAL.md; check_doc 'delivery vocabulary remains explicit' '`REWORK_REQUIRED`, and `DO_NOT_SHIP`' docs/guides/AGENT_MANUAL.md; printf 'VOCABULARY_FAILURES=%s\n' "$fail_count"; if [[ "$fail_count" -ne 0 ]]; then exit 1; fi; printf '%s\n' 'BUG-009 S07 planning-versus-delivery vocabulary: PASS'
```

**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
BUG-009 S07 planning-versus-delivery vocabulary
CHECK: planning terminal status
PASS: planning stops at specs_hardened
PASS: planning delivery is NOT_EVALUATED
CHECK: forbidden delivery implications
PASS: not implemented or tested
PASS: not merge-ready or releasable
PASS: not deployable, delivered, or shipped
CHECK: vocabulary separation
PASS: planning verdict is PLANNING_AUDIT_CLEAN
PASS: planning never emits SHIP_IT
PASS: delivery vocabulary remains explicit
VOCABULARY_FAILURES=0
BUG-009 S07 planning-versus-delivery vocabulary: PASS
```

**Result:** PASS — the overview and manual make `specs_hardened` planning
maturity and delivery `NOT_EVALUATED` unambiguously distinct from delivery
ship/refusal vocabulary.

##### BUG-009 S07 Coherent Rollback Evidence

**Phase:** docs
**Command:**

```bash
cd /Users/pkirsanov/Projects/bubbles && fail_count=0; check_doc() { label="$1"; pattern="$2"; if grep -Fq -- "$pattern" docs/recipes/framework-ops.md; then printf 'PASS: %s\n' "$label"; else printf 'FAIL: %s\n' "$label"; fail_count=$((fail_count + 1)); fi; }; printf '%s\n' 'BUG-009 S07 coherent rollback contract' 'CHECK: rollback unit'; check_doc 'rollback is one canonical source change' 'Rollback the contract as one source change'; check_doc 'complete contract is reverted' 'Revert the complete canonical'; check_doc 'derived outputs are regenerated' 'regenerate derived'; check_doc 'release manifest is regenerated from reverted source' 'the release manifest from that reverted source'; check_doc 'release-check must pass' '`release-check`'; check_doc 'supported upgrade path distributes prior release' 'upgrade path'; printf '%s\n' 'CHECK: forbidden partial rollback'; check_doc 'planning-only exemption cannot remain' 'Do not leave only a planning exemption or prompt change'; check_doc 'audit history cannot be deleted' 'delete `execution.audit` history'; check_doc 'consumer state cannot be rewritten' 'rewrite consumer state'; check_doc 'old bytes cannot be hand-copied' 'hand-copy old'; printf 'ROLLBACK_FAILURES=%s\n' "$fail_count"; if [[ "$fail_count" -ne 0 ]]; then exit 1; fi; printf '%s\n' 'BUG-009 S07 coherent rollback contract: PASS'
```

**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
BUG-009 S07 coherent rollback contract
CHECK: rollback unit
PASS: rollback is one canonical source change
PASS: complete contract is reverted
PASS: derived outputs are regenerated
PASS: release manifest is regenerated from reverted source
PASS: release-check must pass
PASS: supported upgrade path distributes prior release
CHECK: forbidden partial rollback
PASS: planning-only exemption cannot remain
PASS: audit history cannot be deleted
PASS: consumer state cannot be rewritten
PASS: old bytes cannot be hand-copied
ROLLBACK_FAILURES=0
BUG-009 S07 coherent rollback contract: PASS
```

**Result:** PASS — rollback is documented as one source-first contract revert,
followed by derived regeneration, release validation, and supported
installation; partial rollback and audit-history/state rewriting remain
forbidden.

##### BUG-009 S07 Changelog Truth Evidence

**Phase:** docs
**Command:**

```bash
cd /Users/pkirsanov/Projects/bubbles && fail_count=0; check_doc() { label="$1"; pattern="$2"; if grep -Fq -- "$pattern" CHANGELOG.md; then printf 'PASS: %s\n' "$label"; else printf 'FAIL: %s\n' "$label"; fail_count=$((fail_count + 1)); fi; }; printf '%s\n' 'BUG-009 S07 changelog truth contract' 'CHECK: implemented behavior only'; check_doc 'entry is under Unreleased' '## [Unreleased]'; check_doc 'entry identifies BUG-009 source behavior' '### BUG-009 Planning Audit Fix'; check_doc 'registry binding is recorded' 'Registry-bound planning transition audit (BUG-009)'; check_doc 'guard/result contract is recorded' 'Profile-scoped guard and result contracts'; check_doc 'audit attempt/certification contract is recorded' 'Audit attempts and exact-ceiling certification'; check_doc 'S06 evidence is named' 'Source behavior above is backed by the BUG-009 S06'; printf '%s\n' 'CHECK: unexecuted claims excluded'; check_doc 'release packaging is not claimed' 'does not assert release packaging'; check_doc 'downstream upgrade is not claimed' 'downstream upgrade'; check_doc 'installed provenance is not claimed' 'installed-byte provenance'; check_doc 'consumer recertification is not claimed' 'consumer recertification'; check_doc 'BUG-009 closure is not claimed' 'BUG-009 closure'; printf 'CHANGELOG_FAILURES=%s\n' "$fail_count"; if [[ "$fail_count" -ne 0 ]]; then exit 1; fi; printf '%s\n' 'BUG-009 S07 changelog truth contract: PASS'
```

**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
BUG-009 S07 changelog truth contract
CHECK: implemented behavior only
PASS: entry is under Unreleased
PASS: entry identifies BUG-009 source behavior
PASS: registry binding is recorded
PASS: guard/result contract is recorded
PASS: audit attempt/certification contract is recorded
PASS: S06 evidence is named
CHECK: unexecuted claims excluded
PASS: release packaging is not claimed
PASS: downstream upgrade is not claimed
PASS: installed provenance is not claimed
PASS: consumer recertification is not claimed
PASS: BUG-009 closure is not claimed
CHANGELOG_FAILURES=0
BUG-009 S07 changelog truth contract: PASS
```

**Result:** PASS — the Unreleased note records only source behavior already
proven by S06 and explicitly excludes release, installation, downstream, and
bug-closure claims.

##### BUG-009 S07 Validation And S08 Manifest Classification Evidence

**Phase:** docs
**Command 1:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/cli.sh framework-validate`
**Exit Code 1:** 1
**Command 2:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/cli.sh framework-validate --tier=core`
**Exit Code 2:** 0
**Command 3:** `cd /Users/pkirsanov/Projects/bubbles && printf '%s\n' 'BUG-009 S07 final agnosticity validation' 'COMMAND: bash bubbles/scripts/cli.sh agnosticity' 'REPOSITORY: canonical Bubbles source' 'SCOPE: final S07 documentation bytes' 'PLATFORM: macOS' '--- AGNOSTICITY OUTPUT BEGIN ---'; bash bubbles/scripts/cli.sh agnosticity; exit_code=$?; printf '%s\n' '--- AGNOSTICITY OUTPUT END ---' "AGNOSTICITY_EXIT_CODE=$exit_code" 'BUG-009 S07 final agnosticity validation complete'; exit "$exit_code"`
**Exit Code 3:** 0
**Command 4:** `cd /Users/pkirsanov/Projects/bubbles && printf '%s\n' 'BUG-009 S07 release-manifest selftest classification' 'COMMAND: bash bubbles/scripts/release-manifest-selftest.sh' 'EXPECTED_OWNER_IF_STALE: S08 bubbles.releases' '--- RELEASE MANIFEST SELFTEST BEGIN ---'; bash bubbles/scripts/release-manifest-selftest.sh; exit_code=$?; printf '%s\n' '--- RELEASE MANIFEST SELFTEST END ---' "RELEASE_MANIFEST_SELFTEST_EXIT_CODE=$exit_code" 'NO_MANIFEST_MUTATION_PERFORMED=true'; exit "$exit_code"`
**Exit Code 4:** 1
**Command 5:**

```bash
cd /Users/pkirsanov/Projects/bubbles && failures=0; printf '%s\n' 'BUG-009 S07 documentation integrity validation' 'CHECK 1: governance index'; bash bubbles/scripts/governance-index-lint.sh || failures=$((failures + 1)); printf '%s\n' 'CHECK 2: effective managed-doc paths'; bash bubbles/scripts/cli.sh docs-registry effective --paths-only || failures=$((failures + 1)); printf '%s\n' 'CHECK 3: new cross-document targets and anchors'; for target in docs/guides/AGENT_MANUAL.md docs/guides/CONTROL_PLANE_DESIGN.md docs/recipes/framework-ops.md; do if [[ -f "$target" ]]; then printf 'PASS: %s exists\n' "$target"; else printf 'FAIL: %s missing\n' "$target"; failures=$((failures + 1)); fi; done; for contract in 'docs/guides/AGENT_MANUAL.md:^## Registry-Bound Transition Audits$' 'docs/guides/CONTROL_PLANE_DESIGN.md:^### Registry-Bound Transition Audit Contract$' 'docs/recipes/framework-ops.md:^## Inspect And Operate Transition Audits$'; do file="${contract%%:*}"; pattern="${contract#*:}"; if grep -Eq "$pattern" "$file"; then printf 'PASS: %s anchor exists\n' "$file"; else printf 'FAIL: %s anchor missing\n' "$file"; failures=$((failures + 1)); fi; done; printf '%s\n' 'CHECK 4: S07 scoped diff whitespace'; if git diff --check -- README.md docs/guides/AGENT_MANUAL.md docs/guides/CONTROL_PLANE_DESIGN.md docs/recipes/framework-ops.md CHANGELOG.md BUGS.md; then printf '%s\n' 'PASS: scoped git diff --check'; else printf '%s\n' 'FAIL: scoped git diff --check'; failures=$((failures + 1)); fi; printf 'DOCUMENTATION_INTEGRITY_FAILURES=%s\n' "$failures"; if [[ "$failures" -ne 0 ]]; then exit 1; fi; printf '%s\n' 'BUG-009 S07 documentation integrity validation: PASS'
```

**Exit Code 5:** 0
**Claim Source:** interpreted
**Interpretation:** The full aggregate names exactly two failures, both on the
release manifest. The direct manifest selftest reports exactly one issue,
committed-manifest freshness, while all 15 manifest shape/provenance assertions
pass. The S07-owned structural/core tier and agnosticity checks exit 0. Per the
ordered BUG-009 plan, regeneration and release-manifest freshness belong to S08
and no manifest mutation is permitted in S07.
**Output (labeled windows from the complete unfiltered runs):**

```text
==> Stale-deferral lint (live)
[stale-deferral-lint] OK — no lapsed forward-references (current VERSION 7.19.2)
PASS: Stale-deferral lint (live)

Framework validation failed with 2 failing check(s).
Failed checks:
  - Release manifest freshness
  - Release manifest selftest

Framework validation passed (130 self-only check(s) skipped under install-mode=source).
Framework validation passed.

BUG-009 S07 final agnosticity validation
COMMAND: bash bubbles/scripts/cli.sh agnosticity
REPOSITORY: canonical Bubbles source
SCOPE: final S07 documentation bytes
PLATFORM: macOS
--- AGNOSTICITY OUTPUT BEGIN ---
Scanning 456 portable file(s) for agnosticity drift
Portable Bubbles surfaces are project-agnostic and tool-agnostic
--- AGNOSTICITY OUTPUT END ---
AGNOSTICITY_EXIT_CODE=0
BUG-009 S07 final agnosticity validation complete

Running release-manifest selftest...
Scenario: release hygiene generates one complete trust manifest for downstream installs.
Release manifest is stale. Run bubbles/scripts/generate-release-manifest.sh
FAIL: Committed release manifest is current
PASS: Release manifest exists
PASS: Manifest records release version
PASS: Manifest records source git SHA
PASS: Manifest records trust docs digest
PASS: Manifest records framework-managed file count (610)
PASS: Managed checksum inventory includes framework agents
PASS: Managed checksum inventory includes shared CLI surface
PASS: Manifest records source-only file count (49)
PASS: Source-only checksum inventory includes G094 regression test
PASS: Manifest exposes foundation as a supported profile
PASS: Manifest exposes delivery as a supported profile
PASS: Manifest exposes Claude Code as a supported interop source
PASS: Manifest exposes Roo Code as a supported interop source
PASS: Manifest exposes Cursor as a supported interop source
PASS: Manifest exposes Cline as a supported interop source
release-manifest selftest failed with 1 issue(s).

BUG-009 S07 documentation integrity validation
CHECK 1: governance index
governance-index-lint: scanned 169 governance doc(s)
governance-index-lint: indexes consulted: 45
governance-index-lint: PASS — zero orphan docs
CHECK 2: effective managed-doc paths
architecture: README.md
api: docs/API.md
development: README.md
testing: docs/Testing.md
deployment: docs/Deployment.md
operations: docs/Operations.md
CHECK 3: new cross-document targets and anchors
PASS: docs/guides/AGENT_MANUAL.md exists
PASS: docs/guides/CONTROL_PLANE_DESIGN.md exists
PASS: docs/recipes/framework-ops.md exists
PASS: docs/guides/AGENT_MANUAL.md anchor exists
PASS: docs/guides/CONTROL_PLANE_DESIGN.md anchor exists
PASS: docs/recipes/framework-ops.md anchor exists
CHECK 4: S07 scoped diff whitespace
PASS: scoped git diff --check
DOCUMENTATION_INTEGRITY_FAILURES=0
BUG-009 S07 documentation integrity validation: PASS
```

**Result:** PASS for the S07-owned documentation contract. The full aggregate
is nonzero solely because the committed release manifest is stale; that
derived-artifact regeneration and release-package validation remain S08-owned.
No release manifest, version, installer, or downstream file was changed.

##### BUG-009 S07 Concurrent-Change And Boundary Evidence

**Phase:** docs
**Command:** The executed command compared SHA-1 values for all 17 unrelated
dirty/untracked concurrent files against the pre-closeout baseline, checked the
three identifying IMP-020 Agent Manual strings, and rejected dirty paths outside
the six S07 surfaces or the 17 known concurrent paths. The full literal command
and output are preserved in the current terminal session.
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
BUG-009 S07 final concurrent-change and boundary verification
CHECK 1: unrelated concurrent file hashes
PASS: unchanged agents/bubbles.redteam.agent.md sha1=6cdaaac9620b591156e5fcfafc0ac6f6a18f9867
PASS: unchanged agents/bubbles.super.agent.md sha1=c1c46a79389b5a280e72c256e747c873982d710a
PASS: unchanged agents/bubbles_shared/agent-common.md sha1=a942ee689b843bcd9747aef27f8b2977e1f3fb79
PASS: unchanged bubbles/release-manifest.json sha1=af546ecdceeb335ab548d4c66c16ec8fb0cd2bc5
PASS: unchanged bubbles/scripts/adversarial-resolve-selftest.sh sha1=3e3ee1ba528ae26db2fa9a7347aeae18acdf8539
PASS: unchanged bubbles/scripts/adversarial-resolve.sh sha1=efbcb34ee7ebfa6731283415693f2c018d4ee2aa
PASS: unchanged bubbles/workflows.yaml sha1=8d7dea45baa2cd05563cec8ca4e4e74717b63cce
PASS: unchanged docs/CATALOG.md sha1=1dfa34f563ea7e8bd09ce88fe7da4912155d8437
PASS: unchanged docs/guides/WORKFLOW_MODES.md sha1=6b8fda00a48d0a30e1d77a13f3ec6962312ea368
PASS: unchanged docs/recipes/README.md sha1=d8594988ec64be3e00a58139321fc3a1210c9ddc
PASS: unchanged docs/recipes/adversarial-verification.md sha1=bb408a8e64fb3813638fbf8c51aebd521d4fdca0
PASS: unchanged docs/recipes/cross-model-review.md sha1=2517473ee32de403ecef602aec9d99b579e7e43f
PASS: unchanged prompts/bubbles.redteam.prompt.md sha1=e31adaf1d7b1001a7bd03dda6d6a7ae419435d01
PASS: unchanged skills/bubbles-workflow-mode-resolution/SKILL.md sha1=194e69ba66e2105190cf78a1f6443ac6d6671cd0
PASS: unchanged bubbles/eval/schemas/adversarial-sample.schema.json sha1=fcb167e936669032dbfd8964b472f7c93ef02d2a
PASS: unchanged bubbles/scripts/adversarial-aggregate-selftest.sh sha1=226ed99a5f1635b60842ea140e64ae39582fd6a7
PASS: unchanged bubbles/scripts/adversarial-aggregate.sh sha1=7098666908cfa6239e6519447d6e865c4b041c59
CHECK 2: overlapping Agent Manual preserves concurrent IMP-020 section
PASS: IMP-020 Agent Manual section remains present
CHECK 3: authorized S07 surface
S07_UNEXPECTED_PATHS=0
CONCURRENT_HASHES_VERIFIED=17
TOTAL_BOUNDARY_FAILURES=0
BUG-009 S07 final concurrent-change and boundary verification: PASS
```

**Result:** PASS — every unrelated concurrent file retained its exact baseline
hash. The pre-existing IMP-020 section in `AGENT_MANUAL.md` remains present;
S07 added only its isolated transition-audit section. The release manifest was
not regenerated or edited by S07.

**S07 disposition:** terminal `completed_owned`. All six S07 DoD items have
current-session evidence. S08 is now eligible; its required owner is
`bubbles.releases`, with `bubbles.devops` responsible for installer provenance.

#### S08 — Canonical Version, Installer Provenance, And Release Package

- **Status:** Done — v7.20.0 release package, manifest-last regeneration,
  install provenance, supported rollback, and canonical release-check are green
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

- [x] Version/changelog state follows repository policy and is backed by S06/S07 evidence. Evidence: [S08 version and changelog truth evidence](#bug-009-s08-version-and-changelog-truth-evidence).
- [x] Hermetic install proves every new/changed managed interface is copied, executable as needed, listed, checksummed, and byte-identical. Evidence: [S08 DevOps installer/provenance evidence](#bug-009-s08-devops-installerprovenance-evidence) and [S08 provenance fixture repair evidence](#bug-009-s08-provenance-fixture-repair-evidence).
- [x] Derived registries are regenerated from source and `bubbles/release-manifest.json` is regenerated last, never hand-edited. Evidence: [S08 manifest-last regeneration evidence](#bug-009-s08-manifest-last-regeneration-evidence).
- [x] `bash bubbles/scripts/cli.sh release-check` exits zero with full output. Evidence: [S08 canonical release-check evidence](#bug-009-s08-canonical-release-check-evidence).
- [x] Rollback to the prior release is proven through the same installer/provenance path without history deletion or manual copying. Evidence: [S08 supported rollback evidence](#bug-009-s08-supported-rollback-evidence).
- [x] No downstream repository file changed in S08. Evidence: [S08 concurrent-change and downstream boundary evidence](#bug-009-s08-concurrent-change-and-downstream-boundary-evidence).

##### BUG-009 S08 DevOps Installer/Provenance Evidence

**Phase:** release
**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/install-provenance-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output (BUG-009 contract and repair windows from the full unfiltered run):**

```text
PASS: BUG-009 managed file installed: bubbles/scripts/audit-result-contract-lint.sh
PASS: BUG-009 executable mode is correct: bubbles/scripts/audit-result-contract-lint.sh
PASS: BUG-009 .manifest owns: bubbles/scripts/audit-result-contract-lint.sh
PASS: BUG-009 .checksums records installed bytes: bubbles/scripts/audit-result-contract-lint.sh
PASS: BUG-009 installed bytes match canonical source: bubbles/scripts/audit-result-contract-lint.sh
PASS: BUG-009 release manifest records managed checksum: bubbles/scripts/audit-result-contract-lint.sh
PASS: BUG-009 managed file installed: bubbles/scripts/transition-contract-resolver.sh
PASS: BUG-009 executable mode is correct: bubbles/scripts/transition-contract-resolver.sh
PASS: BUG-009 .manifest owns: bubbles/scripts/transition-contract-resolver.sh
PASS: BUG-009 .checksums records installed bytes: bubbles/scripts/transition-contract-resolver.sh
PASS: BUG-009 installed bytes match canonical source: bubbles/scripts/transition-contract-resolver.sh
PASS: BUG-009 release manifest records managed checksum: bubbles/scripts/transition-contract-resolver.sh
PASS: BUG-009 managed file installed: agents/bubbles.audit.agent.md
PASS: BUG-009 .manifest owns: agents/bubbles.audit.agent.md
PASS: BUG-009 .checksums records installed bytes: agents/bubbles.audit.agent.md
PASS: BUG-009 installed bytes match canonical source: agents/bubbles.audit.agent.md
PASS: BUG-009 managed file installed: agents/bubbles_shared/workflow-phase-engine.md
PASS: BUG-009 .manifest owns: agents/bubbles_shared/workflow-phase-engine.md
PASS: BUG-009 .checksums records installed bytes: agents/bubbles_shared/workflow-phase-engine.md
PASS: BUG-009 installed bytes match canonical source: agents/bubbles_shared/workflow-phase-engine.md
PASS: BUG-009 managed file installed: bubbles/workflows/modes.yaml
PASS: BUG-009 .manifest owns: bubbles/workflows/modes.yaml
PASS: BUG-009 .checksums records installed bytes: bubbles/workflows/modes.yaml
PASS: BUG-009 installed bytes match canonical source: bubbles/workflows/modes.yaml
PASS: BUG-009 source-only regression is not installed: tests/regression/test_23_planning_audit_contract.sh
PASS: BUG-009 source-only regression is absent from .manifest: tests/regression/test_23_planning_audit_contract.sh
PASS: BUG-009 source-only regression is absent from .checksums: tests/regression/test_23_planning_audit_contract.sh
PASS: BUG-009 release manifest records source-only checksum: tests/regression/test_23_planning_audit_contract.sh
PASS: BUG-009 checksum snapshot detects managed-file byte drift
PASS: BUG-009 executable mode is correct: bubbles/scripts/transition-contract-resolver.sh
PASS: BUG-009 installed bytes match canonical source: bubbles/scripts/transition-contract-resolver.sh
PASS: BUG-009 checksum snapshot detects managed-file removal
PASS: BUG-009 executable mode is correct: bubbles/scripts/audit-result-contract-lint.sh
PASS: BUG-009 installed bytes match canonical source: bubbles/scripts/audit-result-contract-lint.sh
PASS: Installed manifest reports 610 managed files (>=300 sanity floor)
install-provenance selftest passed.
```

**Result:** PASS — the real local-source installer carried all 21 changed
install-managed BUG-009 interfaces plus the source-only persistent regression.
For every managed path, the selftest checked presence, required executable mode,
exact `.manifest` ownership, `.checksums` membership against installed bytes,
canonical-to-installed byte identity, and release-manifest checksum provenance.
It then detected resolver byte/mode drift and audit-lint removal, and proved a
supported re-install restores bytes, executable mode, membership, and checksum
provenance. The run executed successfully on macOS using portable shell forms.

**Installer disposition:** the existing broad-copy paths in `install.sh` cover
top-level scripts, schemas, workflow registries, agents, shared contracts,
templates, and docs. No installer behavior gap was observed, so `install.sh`
was not changed. Version, changelog, generated workflow, release manifest,
release docs, release-check, rollback, and downstream upgrade remain untouched
by this DevOps slice and are not claimed complete.

**S08 DevOps disposition:** terminal `route_required`. Installer provenance is
ready for release ownership; `bubbles.releases` remains required for the
canonical version, derived regeneration, final release manifest, release-check,
and rollback evidence before S08 can become Done.

##### BUG-009 S08 Version And Changelog Truth Evidence

**Phase:** release
**Command:** A focused shell assertion checked `VERSION`, the `Unreleased` and
`v7.20.0` headings, the BUG-009 behavior/evidence statements, all four explicit
non-claims, and `git diff --check -- VERSION CHANGELOG.md`.
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
BUG-009 S08 version and changelog truth
CHECK: semantic version
PASS: VERSION is 7.20.0
PASS: Unreleased heading remains available
PASS: 7.20.0 release heading exists
PASS: minor-release theme names planning transition audits
CHECK: proven behavior and non-claims
PASS: BUG-009 behavior is named
PASS: S06 evidence basis is retained
PASS: downstream upgrade remains unclaimed
PASS: GuestHost installed-byte provenance remains unclaimed
PASS: consumer recertification remains unclaimed
PASS: BUG-009 closure remains unclaimed
VERSION_CHANGELOG_FAILURES=0
BUG-009 S08 version and changelog truth: PASS
```

**Result:** PASS — `7.20.0` is the repository-policy MINOR bump for the new
registry-bound transition-audit capability. The release note claims only the
S06/S07-proven BUG-009 behavior and explicitly excludes downstream upgrade,
GuestHost installed-byte provenance, consumer recertification, and bug closure.

##### BUG-009 S08 Provenance Fixture Repair Evidence

**Phase:** release
**Initial command:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/cli.sh release-check`
**Initial Exit Code:** 1
**Focused command after repair:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/install-provenance-selftest.sh`
**Focused Exit Code:** 0
**Claim Source:** executed
**Output (failure discriminator followed by the final focused-run window):**

```text
Framework validation failed with 1 failing check(s).
Failed checks:
  - Install provenance selftest
FAIL: Framework validation
Release check failed with 1 failing check(s).

fatal: a branch named 'scope02"quoted' already exists

PASS: Unsafe local-source refs fall back to literal local-source provenance
PASS: BUG-009 managed file installed: bubbles/scripts/audit-result-contract-lint.sh
PASS: BUG-009 .manifest owns: bubbles/scripts/audit-result-contract-lint.sh
PASS: BUG-009 .checksums records installed bytes: bubbles/scripts/audit-result-contract-lint.sh
PASS: BUG-009 installed bytes match canonical source: bubbles/scripts/audit-result-contract-lint.sh
PASS: BUG-009 release manifest records managed checksum: bubbles/scripts/audit-result-contract-lint.sh
PASS: BUG-009 source-only regression is absent from .manifest: tests/regression/test_23_planning_audit_contract.sh
PASS: BUG-009 checksum snapshot detects managed-file byte drift
PASS: BUG-009 checksum snapshot detects managed-file removal
PASS: Installed manifest reports 612 managed files (>=300 sanity floor)
install-provenance selftest passed.
```

**Result:** PASS — the first canonical release check exposed a real S08-owned
fixture defect: copied linked-worktree Git metadata made the unsafe-ref fixture
reuse a shared branch. The selftest now replaces copied `.git` metadata with an
independent temporary repository before dirtying or branching either local
source fixture. The focused rerun passes all install, ownership, checksum,
byte-parity, executable-mode, drift/removal, and source-only assertions. No
installer production behavior changed.

##### BUG-009 S08 Manifest-Last Regeneration Evidence

**Phase:** release
**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/regen-derived.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
==> regenerating: framework stats (README / CHEATSHEET / html / framework-stats.*)
Updated Bubbles framework stats: 41 Agents · 109 Gates · 60 Workflow Modes · 30 Phases (v7.20.0)
==> regenerating: cheatsheet
cheatsheet generated: 57 modes, 59 aliases, 92 vocab terms
==> regenerating: capability-ledger docs
Updated capability ledger docs: 22 shipped, 1 partial, 0 proposed
==> regenerating: release manifest (LAST — checksums everything above)
Updated release manifest: 7.20.0 (610 managed files)

Verifying derived-artifact freshness...
==> verifying fresh: framework stats
Framework stats are current: 41 Agents · 109 Gates · 60 Workflow Modes · 30 Phases (v7.20.0)
==> verifying fresh: cheatsheet
==> verifying fresh: capability-ledger docs
Capability ledger docs are current: 22 shipped, 1 partial, 0 proposed
==> verifying fresh: release manifest
Release manifest is current: 7.20.0 (610 managed files)
regen-derived: all derived artifacts are fresh.
```

**Result:** PASS — the canonical wrapper regenerated all derived families in
dependency order and explicitly generated `bubbles/release-manifest.json` last.
Its immediate check phase found every generated surface fresh. The wrapper, not
a hand edit, produced the final manifest bytes.

##### BUG-009 S08 Supported Rollback Evidence

**Phase:** release
**Commands:** A detached worktree at pre-BUG-009 commit
`c34ba97cf1d6f646b40f031cad41aa72d76a622b` ran its own
`bash bubbles/scripts/cli.sh release-check`; a temporary Git consumer installed
the current `7.20.0` source through `install.sh --local-source`, then reinstalled
the clean prior worktree through the same installer. A final assertion command
checked version/provenance, candidate-only pruning, prior byte/checksum parity,
the audit-history sentinel, and installed `framework-write-guard`.
**Exit Codes:** 0, 0, 0, 0
**Claim Source:** executed
**Output:**

```text
BUG-009 S08 supported rollback final verification
PASS: pre-BUG-009 source release-check exited 0
PASS: rollback source is exact pre-BUG-009 commit c34ba97
PASS: installed rollback version is 7.19.2
PASS: install provenance records exact rollback SHA
PASS: install provenance records clean rollback source
PASS: installer pruned candidate-only bubbles/scripts/audit-result-contract-lint-selftest.sh
PASS: installer pruned candidate-only bubbles/scripts/audit-result-contract-lint.sh
PASS: installer pruned candidate-only bubbles/scripts/transition-contract-resolver-selftest.sh
PASS: installer pruned candidate-only bubbles/scripts/transition-contract-resolver.sh
PASS: installer pruned candidate-only bubbles/scripts/adversarial-aggregate-selftest.sh
PASS: installer pruned candidate-only bubbles/scripts/adversarial-aggregate.sh
PASS: prior byte/checksum parity bubbles/scripts/framework-validate.sh
PASS: prior byte/checksum parity bubbles/scripts/state-transition-guard.sh
PASS: prior byte/checksum parity bubbles/workflows/modes.yaml
PASS: prior byte/checksum parity agents/bubbles.audit.agent.md
PASS: prior byte/checksum parity agents/bubbles_shared/workflow-phase-engine.md
PASS: prior byte/checksum parity docs/guides/AGENT_MANUAL.md
PASS: prior byte/checksum parity docs/recipes/framework-ops.md
PASS: audit-history sentinel bytes are unchanged
Installed release manifest: version=7.19.2 gitSha=c34ba97cf1d6f646b40f031cad41aa72d76a622b
Install provenance: mode=local-source sourceRef=local-source sourceGitSha=c34ba97cf1d6f646b40f031cad41aa72d76a622b dirty=false
Managed-file integrity: downstream framework-managed files still match the installed upstream snapshot
PASS: installed grant-aware integrity guard exits 0
ROLLBACK_VERIFICATION_FAILURES=0
BUG-009 S08 supported rollback final verification: PASS
```

**Result:** PASS — rollback used the same supported installer path in a
throwaway consumer, not history deletion or manual copying. It restored the
last pre-BUG-009 `7.19.2` source, pruned candidate-only scripts, restored prior
managed bytes/checksums and executable modes, passed the installed integrity
guard, and left persisted audit-history bytes unchanged. No real downstream
repository participated in the rehearsal.

##### BUG-009 S08 Canonical Release-Check Evidence

**Phase:** release
**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/cli.sh release-check`
**Exit Code:** 0
**Claim Source:** executed
**Output (final verdict window from the full 1,031-line unfiltered run):**

```text
stale-deferral-lint-selftest: 11 pass, 0 fail
PASS: Stale-deferral lint selftest

==> Stale-deferral lint (live)
[stale-deferral-lint] OK — no lapsed forward-references (current VERSION 7.20.0)
PASS: Stale-deferral lint (live)

Framework validation passed.
PASS: Framework validation

==> Capability ledger docs freshness
Capability ledger docs are current: 22 shipped, 1 partial, 0 proposed
PASS: Capability ledger docs freshness

==> Framework stats freshness
Framework stats are current: 41 Agents · 109 Gates · 60 Workflow Modes · 30 Phases (v7.20.0)
PASS: Framework stats freshness

==> Cheatsheet freshness (v6.0 / B7)
PASS: Cheatsheet freshness (v6.0 / B7)

==> Release manifest freshness
Release manifest is current: 7.20.0 (610 managed files)
PASS: Release manifest freshness

==> Required release files
PASS: Required release files

==> No stray temp or backup files
PASS: No stray temp or backup files

Release check passed.
```

**Result:** PASS — the exact canonical release command exited 0 after the
focused provenance repair and final manifest-last regeneration. Framework
validation, capability-ledger docs, framework stats, cheatsheet, release
manifest, required files, and stray-file checks are all green.

##### BUG-009 S08 Concurrent-Change And Downstream Boundary Evidence

**Phase:** release
**Command:** The executed boundary assertion compared Git blob IDs for all 21
non-S08 authored/concurrent IMP-020 and adversarial-evaluation paths against the
pre-regeneration baseline, compared full porcelain status for all five visible
downstream repos, and ran scoped `git diff --check` over S08/generated paths.
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
PASS: all 21 non-S08 protected authored/concurrent paths retain exact bytes
PASS: QuantitativeFinance status unchanged
PASS: GuestHost status unchanged
PASS: WanderAide status unchanged
PASS: smackerel status unchanged
PASS: knb status unchanged
PASS: S08 and generated surfaces pass diff whitespace checks
CONCURRENT_PROTECTED_PATHS=21
DOWNSTREAM_REPOS_VERIFIED=5
S08_FINAL_BOUNDARY=PASS
```

**Result:** PASS — every protected concurrent authored/untracked path retained
its exact pre-S08 bytes. No downstream status changed. S08 changed only its
version/changelog, provenance selftest, generator-owned release outputs, and
this BUG-009 evidence/status record; `install.sh` and `regen-derived.sh` needed
no source edit.

**S08 disposition:** terminal `completed_owned`. All six S08 DoD items have
execution-backed evidence. No S08 finding remains unresolved. S09 is now
eligible and routes to `bubbles.devops` for the supported GuestHost upgrade and
installed provenance verification. S10 and overall BUG-009 closure remain
untouched and open.

#### S09 — Supported GuestHost Upgrade And Provenance Verification

- **Status:** Blocked — canonical manifest freshness was stale, so the required
  no-mutation branch validated the existing installed snapshot; a concurrent
  S10-shaped process then changed protected Spec 151 `state.json` after S09's
  exact GuestHost baseline, preventing a clean preservation verdict
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

- [x] Canonical `release-check` evidence predates the GuestHost upgrade. Evidence: [S09 freshness branch and release chronology evidence](#bug-009-s09-freshness-branch-and-release-chronology-evidence).
- [x] GuestHost followed the required stale-manifest no-mutation branch; the existing supported local-source install has no manual framework-managed drift. Evidence: [S09 freshness branch and release chronology evidence](#bug-009-s09-freshness-branch-and-release-chronology-evidence) and [S09 installed integrity, doctor, and framework validation evidence](#bug-009-s09-installed-integrity-doctor-and-framework-validation-evidence).
- [x] Manifest membership, checksums, bytes, executable bits, and release identity match for every BUG-009 managed surface in the installed snapshot. Evidence: [S09 installed release identity and managed-surface parity evidence](#bug-009-s09-installed-release-identity-and-managed-surface-parity-evidence).
- [x] Installed framework-write integrity, doctor, and framework validation pass with real output. Evidence: [S09 installed integrity, doctor, and framework validation evidence](#bug-009-s09-installed-integrity-doctor-and-framework-validation-evidence).
- [ ] GuestHost Spec 151 and product source remain unchanged before S10 audit.
  > **Uncertainty Declaration**
  > **What was attempted:** Exact pre/post GuestHost Git-visible fingerprinting plus per-file SHA-256 inventory for all Spec 151 files.
  > **What was observed:** GuestHost first remained exactly at fingerprint `8a99b7b254c7e9d1c6884c79c5b6f74ee65db34f3b0699c00d24b177e291d08b`; later, Spec 151 `state.json` changed from baseline SHA-256 `eb2018386f8d17a72b1eff19a65a310056d4a53bfe435a26a2c3e3f1b5da1ee2` to `1ca81b20b3627b7b0369fbb01a4e77aecde32287edad05333e42697a21eb426f` with S10 audit/validate transition fields.
  > **Why this is uncertain:** The mutation occurred outside this invocation after the clean S09 checkpoint. Reverting it would destroy concurrent work, while accepting it would falsely claim S09 preserved the protected pre-S10 bytes.
  > **What would resolve this:** `bubbles.audit` must reconcile the concurrent S10 result with this S09 evidence, establish the authoritative Spec 151 state, and return a stable protected-byte baseline before S09 can be terminal.
- [ ] No other downstream repository is patched or upgraded as part of BUG-009 consumer proof.
  > **Uncertainty Declaration**
  > **What was attempted:** Exact pre/post fingerprints for QuantitativeFinance, GuestHost, WanderAide, smackerel, and knb, with only read-only status/hash commands outside GuestHost.
  > **What was observed:** WanderAide remained exact; unrelated QuantitativeFinance, smackerel, and knb deployment work changed concurrently, and GuestHost later received the protected Spec 151 state mutation. No S09 command invoked an installer, upgrade, patch, build, deploy, or file write in any downstream repo.
  > **Why this is uncertain:** Absolute byte equality cannot be claimed while independent writers are changing those worktrees, even though S09 itself issued no mutating downstream command.
  > **What would resolve this:** Freeze or coordinate the concurrent writers, take a new stable downstream fingerprint checkpoint, and rerun the final read-only equality assertion.

##### BUG-009 S09 Freshness Branch And Release Chronology Evidence

**Phase:** deploy
**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/generate-release-manifest.sh --check` followed by the executed expected-stale branch assertion shown below
**Exit Code:** 1 for the canonical freshness check; 0 for the expected-stale branch assertion
**Claim Source:** executed
**Output:**

```text
BUG-009 S09 canonical freshness branch gate
COMMAND: bash bubbles/scripts/generate-release-manifest.sh --check
Release manifest is stale. Run bubbles/scripts/generate-release-manifest.sh
FRESHNESS_EXIT_CODE=1
EXPECTED_STALE_EXIT=1
GUESTHOST_UPGRADE_EXECUTED=false
VALIDATION_TARGET=existing-installed-snapshot
INSTALLED_VERSION=7.20.0
INSTALLED_AT=2026-07-12T04:28:28Z
INSTALL_MODE=local-source
PASS: stale manifest selected the required no-mutation branch
BUG-009 S09 freshness/no-upgrade branch: PASS
```

**Result:** PASS — freshness was checked before any consumer operation. The
canonical manifest was stale, so S09 did not invoke `upgrade`, `install.sh`, or
any copy/patch path and instead validated the existing installed snapshot, as
required by the operator's branch contract.

**Phase:** deploy
**Command:** The executed read-only chronology assertion parsed the installed release-manifest offset timestamp with macOS `date -j -f`, parsed the UTC installation timestamp, rejected empty/non-numeric epochs, and checked the prior S08 release-check evidence in this file.
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
INSTALLED_VERSION=7.20.0
RELEASE_MANIFEST_VERSION=7.20.0
RELEASE_MANIFEST_GENERATED_AT=2026-07-11T13:12:38-07:00
GUESTHOST_INSTALLED_AT=2026-07-12T04:28:28Z
RELEASE_MANIFEST_GENERATED_EPOCH=1783800758
GUESTHOST_INSTALLED_EPOCH=1783830508
GENERATION_PRECEDES_INSTALL_BY_SECONDS=29750
PASS: canonical BUGS.md contains prior S08 release-check evidence
PASS: prior S08 evidence contains observed release-check success token
PASS: installed release-manifest generation predates GuestHost installation
BUG-009 S09 release/install chronology: PASS
```

**Result:** PASS — the installed `7.20.0` manifest was generated 29,750
seconds before the GuestHost install, and the successful canonical S08
release-check evidence already precedes this scope. An earlier UTC-only helper
attempt returned an empty epoch for the offset timestamp and was discarded;
only the strict numeric offset-aware rerun above supports this claim.

##### BUG-009 S09 Installed Release Identity And Managed-Surface Parity Evidence

**Phase:** deploy
**Command:** The executed read-only assertion enumerated the exact 8 executable and 13 non-executable BUG-009 install-managed paths from the canonical S08 provenance selftest, then checked unique `.manifest`, `.checksums`, and installed `release-manifest.json` membership, actual SHA-256 bytes, executable classification, release identity, and source-only regression classification.
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
PASS: release identity version=7.20.0
PASS: install provenance mode=local-source sourceRef=main
PASS: source SHA equals release-manifest SHA=9b785d7da7554082cfe0232998ef72cc99637087
PASS: recorded source SHA exists in canonical Git object database
PASS: sourceDirty explicitly recorded as true
PASS: installedAt=2026-07-12T04:28:28Z
PASS: release manifest declares 610 managed files
OBSERVED: installed release manifest differs from current stale canonical manifest
PASS: bubbles/scripts/audit-result-contract-lint-selftest.sh manifest=1 checksums=1 release=1 sha256=4b5058b7f69ed0bd7a73ece889556175ebc8cd950f4f6789abb939084459b04e executable=yes canonicalWorkingTree=match
PASS: bubbles/scripts/audit-result-contract-lint.sh manifest=1 checksums=1 release=1 sha256=e73c4fce2c5c9cdc16f5bcdbb29224e036543f88996938690e12b021b8042839 executable=yes canonicalWorkingTree=match
PASS: bubbles/scripts/framework-validate.sh manifest=1 checksums=1 release=1 sha256=7378aabb1f152a5b12ab873383576c4c5815eadb33626b7eecc5cfd417264261 executable=yes canonicalWorkingTree=post-release-drift
PASS: bubbles/scripts/state-transition-guard-perf-selftest.sh manifest=1 checksums=1 release=1 sha256=8326f217554267b09afd1be3e468e34107002d51e56b56452ca7cf9cc0c45c53 executable=yes canonicalWorkingTree=match
PASS: bubbles/scripts/state-transition-guard-selftest.sh manifest=1 checksums=1 release=1 sha256=20593a047f006cde0eb3db51f1c50b27c3230a46344d35aeea27e1da83dfd3ea executable=yes canonicalWorkingTree=match
PASS: bubbles/scripts/state-transition-guard.sh manifest=1 checksums=1 release=1 sha256=7851c003dde98e4a28f6448599554352c3891c19883f33eed9f68ae495da1cae executable=yes canonicalWorkingTree=match
PASS: bubbles/scripts/transition-contract-resolver-selftest.sh manifest=1 checksums=1 release=1 sha256=e3cad9d2319d10ed7c7883bbb3995b58d150d1cb25ccb99f1777dfd431cd09c0 executable=yes canonicalWorkingTree=match
PASS: bubbles/scripts/transition-contract-resolver.sh manifest=1 checksums=1 release=1 sha256=5750f6c15bf5bd86ae443b19927dff36f284d122865e0c97b33c6abdf3a37050 executable=yes canonicalWorkingTree=match
PASS: bubbles/schemas/workflows.schema.json manifest=1 checksums=1 release=1 sha256=91dc038dffa6cd80d3015d0de71ac1f1abca11fe231e62837d6b05a16df59c19 executable=no canonicalWorkingTree=match
PASS: bubbles/workflows/modes.yaml manifest=1 checksums=1 release=1 sha256=0b408864aaea4a5008f395f3acc71b5d60a883c1104c9d620d9508f237c2fac4 executable=no canonicalWorkingTree=match
PASS: bubbles/workflows.yaml manifest=1 checksums=1 release=1 sha256=97c87a979420d75156d8fec7ca603ab8eb637f0070ae6932e538776a2ef97629 executable=no canonicalWorkingTree=match
PASS: agents/bubbles.audit.agent.md manifest=1 checksums=1 release=1 sha256=61ac157cc1b43849dece5e1c346c6c57a5e3416fa76b4dac6975d663601edf7b executable=no canonicalWorkingTree=match
PASS: agents/bubbles.validate.agent.md manifest=1 checksums=1 release=1 sha256=69c0ca8dfbfaf11a40724f8ce8a4cd2c8c554923f720c8e90a07c4c1f9c59ac8 executable=no canonicalWorkingTree=match
PASS: agents/bubbles_shared/feature-templates.md manifest=1 checksums=1 release=1 sha256=cc79d0f237b69a992216866f68179a5ba8a8c516514330b20b3ca4134e87059c executable=no canonicalWorkingTree=match
PASS: agents/bubbles_shared/scope-templates.md manifest=1 checksums=1 release=1 sha256=6ededca8b964873896a7f196af4fb63813c46e05b554f73235c1d02144eac410 executable=no canonicalWorkingTree=match
PASS: agents/bubbles_shared/scope-workflow.md manifest=1 checksums=1 release=1 sha256=113486001f4116418aec227d654c1bb7c662ef3f3dd63120c143ae0cbb316431 executable=no canonicalWorkingTree=match
PASS: agents/bubbles_shared/validation-profiles.md manifest=1 checksums=1 release=1 sha256=fa660f030cfdd2c63af56d5d943d7460bcd9d1cee1443353a1e631ed705038b9 executable=no canonicalWorkingTree=match
PASS: agents/bubbles_shared/workflow-phase-engine.md manifest=1 checksums=1 release=1 sha256=5d3f716010809943559cc37a684d68462b8dbcbdb295969ba3eb4f32ce573780 executable=no canonicalWorkingTree=match
PASS: docs/guides/AGENT_MANUAL.md manifest=1 checksums=1 release=1 sha256=77573e1d69e4db9db65552770b58f8bcb3923bf8e3febdc08133a71acfc12584 executable=no canonicalWorkingTree=match
PASS: docs/guides/CONTROL_PLANE_DESIGN.md manifest=1 checksums=1 release=1 sha256=862ae96b12133337ee6d960357e69aa7de633eb9904cd0da15dd0b490408c320 executable=no canonicalWorkingTree=match
PASS: docs/recipes/framework-ops.md manifest=1 checksums=1 release=1 sha256=9737f4a84dd2a4bf3cad5582f67395c8d0c47c9ab5570ccf1357bb580cca1d47 executable=no canonicalWorkingTree=match
PASS: source-only regression release checksum=9ad8f348e8afa47b5828b997c776233cc784fb920adccaf7a348a8c44a7f9a04 and downstream absence are correct
BUG009_MANAGED_TOTAL=21
BUG009_MEMBERSHIP_AND_CHECKSUM_PASS=21
BUG009_EXECUTABLE_CLASSIFICATION_PASS=21
CANONICAL_WORKTREE_MATCH=20
CANONICAL_POST_RELEASE_DRIFT=1
SOURCE_DIRTY_RECORDED=true
CHECK_FAILURES=0
BUG-009 S09 installed release identity and managed-surface parity: PASS
```

**Result:** PASS — every BUG-009 install-managed path appears exactly once in
all three installed provenance surfaces, and each actual installed SHA-256 and
executable classification matches that snapshot. The persistent regression is
correctly recorded under `sourceOnlyFileChecksums` and absent downstream.

**Provenance qualification:** this is a supported, internally exact
local-source snapshot, not a clean published-release claim. The recorded
`sourceDirty=true` is material: an additional read-only Git-object probe found
17/21 byte matches to commit `9b785d7`, while four generated release surfaces
came from the dirty release tree; two new scripts were normalized executable by
the installer while their recorded commit modes were `100644`. Those expected
dirty-source differences do not conflict with the installed manifest/checksum
parity above and must remain visible to S10 audit.

##### BUG-009 S09 Installed Integrity Doctor And Framework Validation Evidence

**Phase:** deploy
**Command:** `cd /Users/pkirsanov/Projects/GuestHost && bash .github/bubbles/scripts/cli.sh framework-write-guard`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
BUG-009 S09 installed framework-write integrity
COMMAND: bash .github/bubbles/scripts/cli.sh framework-write-guard
Checking downstream framework-managed files against .github/bubbles/.checksums
Installed release manifest: version=7.20.0 gitSha=9b785d7da7554082cfe0232998ef72cc99637087
Install provenance: mode=local-source sourceRef=main sourceGitSha=9b785d7da7554082cfe0232998ef72cc99637087 dirty=true
Supported profiles: foundation, delivery, production, assured
Supported interop sources: claude-code, roo-code, cursor, cline
Installed from a dirty local source checkout. This is not a clean published release install.
Managed-file integrity: downstream framework-managed files still match the installed upstream snapshot
FRAMEWORK_WRITE_GUARD_EXIT_CODE=0
EXPECTED_EXIT_CODE=0
BUG-009 S09 installed framework-write integrity: PASS
```

**Phase:** deploy
**Command:** `cd /Users/pkirsanov/Projects/GuestHost && bash .github/bubbles/scripts/cli.sh doctor`
**Exit Code:** 0
**Claim Source:** executed
**Output (trust/integrity and final verdict window from the full unfiltered run):**

```text
Framework Integrity
  Core agents installed (42)
  Governance scripts installed (250)
  Workflow config present
  Control-plane policy registry present (.specify/memory/bubbles.config.json)
  All scripts executable
  Bubbles version: 7.20.0
  Portable Bubbles surfaces pass agnosticity lint
  Installed release manifest: version=7.20.0 gitSha=9b785d7da7554082cfe0232998ef72cc99637087
  Install provenance: mode=local-source sourceRef=main sourceGitSha=9b785d7da7554082cfe0232998ef72cc99637087 dirty=true
  Installed from a dirty local source checkout. This is not a clean published release install.
  Managed-file integrity: downstream framework-managed files still match the installed upstream snapshot
  Workflow inventory and documented control-plane surfaces are consistent
  Agent instruction budgets are within the hard limit
  Runtime lease registry readable
  Framework drift advisory: 5 drifted, 5 missing vs release manifest (run 'bubbles-drift-check.sh' for detail)
  Governance hub snapshot: top hub is critical-requirements.md (in-degree 52, shared-module)
  Project config files exist
  No unfilled TODO markers
  specs/ directory exists
  No custom gate scripts defined
  Project scan config present (.github/bubbles-project.yaml)
  Observability posture: WIRED
Result: 17 passed, 0 failed, 0 advisory
```

**Phase:** deploy
**Command:** `cd /Users/pkirsanov/Projects/GuestHost && bash .github/bubbles/scripts/cli.sh framework-validate`
**Exit Code:** 0
**Claim Source:** executed
**Output (final verdict window from the full 44 KB unfiltered run):**

```text
PASS: Case 9: missing VERSION fails (exit 1)
PASS: Case 10: lapsed caught alongside a legit future deferral (exit 1)
PASS: Case 11: own selftest path is excluded (exit 0)

stale-deferral-lint-selftest: 11 pass, 0 fail
PASS: Stale-deferral lint selftest

==> Stale-deferral lint (live)
SKIP: Stale-deferral lint (live) (framework-source-only; install-mode=downstream)

Framework validation passed (35 self-only check(s) skipped under install-mode=downstream). Run from a framework-source tree to execute them.
Framework validation passed.
EXIT_CODE=0
```

**Result:** PASS — installed managed-file integrity, doctor, and the downstream
framework validation all exit zero. Doctor retains two honest non-blocking
signals: dirty local-source provenance and a `5 drifted, 5 missing` advisory
against today's newer canonical release manifest. The installed validation
executed downstream checks and explicitly skipped 35 framework-source-only
checks by contract.

##### BUG-009 S09 Downstream Preservation Evidence

**Phase:** deploy
**Command:** The executed pre-validation fingerprint serialized each repository's HEAD, porcelain status, full tracked/staged binary diff, untracked paths, and untracked blob hashes; the post-validation assertion recomputed the same SHA-256 values. Canonical `BUGS.md` was excluded because it is S09's sole authorized edit.
**Exit Code:** 1 for the absolute six-repository equality assertion because four unrelated repositories changed concurrently; 0 for GuestHost and WanderAide preservation assertions
**Claim Source:** executed
**Output:**

```text
FAIL: canonical Bubbles excluding BUGS.md changed expected=97f67795722cede1809f28c65e290024174b781b30a7cf79f23047427d503eb1 actual=567d95955b61412196c639f77c5e78d5376191aa7b131e557428029075712bb5
PASS: GuestHost complete Git-visible tree (includes Spec 151 and product source) unchanged sha256=8a99b7b254c7e9d1c6884c79c5b6f74ee65db34f3b0699c00d24b177e291d08b
FAIL: QuantitativeFinance complete Git-visible tree changed expected=ba3df521ff7aa5d03f22a36afe8938e563118b9227085e5605a6c934102ec511 actual=2fd0583faae6c0cb03c9a07af953c7c0671d9127dd77bc4ffb1a3c2875ae5485
PASS: WanderAide complete Git-visible tree unchanged sha256=4fe638f8ca609406acb2fdd26cf2f43bd50212a04a0c2fa50a30ddb46208586e
FAIL: smackerel complete Git-visible tree changed expected=f96d6eda5f17e933b49f135db35adc9293b2a8dd172a64dd7a7c400cc2189cb6 actual=7d10742dfd190509f76df1a8b0f651a3ae13fa72e1575553aea377b6567a4fd0
FAIL: knb complete Git-visible tree changed expected=c34881a7cef4ca2512ab2f55395a3f047a996c7f5ddf6a0f904b81e37a0747f4 actual=e14a74e28dba3851a17fa267d70caf36927eb1be752b20d67826fb25adf16756
PRESERVATION_CHECKS=6
PRESERVATION_FAILURES=4
BUG-009 S09 pre/post worktree preservation: FAIL
```

**Interpretation:** GuestHost's complete Git-visible projection is exactly
unchanged, directly preserving every Spec 151 and product byte as well as all
pre-existing dirty work. WanderAide is also byte-identical. During the
read-only GuestHost validation window, unrelated canonical recipe work and
active QuantitativeFinance, smackerel, and knb deployment edits appeared. S09
issued no mutating command in those repositories and did not revert or absorb
the concurrent work. A later final checkpoint detected a second concurrent
wave, including the protected Spec 151 mutation below; therefore this earlier
clean GuestHost result cannot support terminal S09 preservation.

##### BUG-009 S09 Concurrent S10 Mutation Blocker Evidence

**Phase:** deploy
**Command:** The executed read-only discriminator compared the current Spec 151 `state.json` SHA-256 with S09's pre-validation baseline and projected the transition-owned status, active agent, phase, certification, and promotion fields with `jq`.
**Exit Code:** 0 for successful blocker detection
**Claim Source:** executed
**Output:**

```text
BUG-009 S09 protected Spec 151 mutation detector
SPEC151_STATE_BASELINE_SHA256=eb2018386f8d17a72b1eff19a65a310056d4a53bfe435a26a2c3e3f1b5da1ee2
SPEC151_STATE_CURRENT_SHA256=1ca81b20b3627b7b0369fbb01a4e77aecde32287edad05333e42697a21eb426f
STATE_HASH_CHANGED=true
CURRENT_TOP_LEVEL_STATUS=specs_hardened
CURRENT_EXECUTION_ACTIVE_AGENT=bubbles.audit
CURRENT_EXECUTION_PHASE=audit
CURRENT_CERTIFICATION_STATUS=specs_hardened
CURRENT_CERTIFIED_PHASES=validate,audit
CURRENT_PROMOTED_BY=bubbles.validate
CURRENT_PROMOTION_TARGET=specs_hardened
PASS: concurrent S10-shaped mutation detected and preserved without rollback
S09_PROTECTED_BYTE_VERDICT=BLOCKED
BUG-009 S09 concurrent-mutation detector: PASS
```

**Result:** BLOCKED — the current diff changes top-level and certification
status from `not_started` to `specs_hardened`, adds the audit phase claim, and
adds validate-owned promotion metadata. Those are S10 surfaces and appeared
after S09 had already proved an unchanged GuestHost fingerprint. This
invocation neither produced nor reverted them. S09 cannot honestly become Done
or route as clean until `bubbles.audit` reconciles the concurrent transition.

**S09 disposition:** terminal `blocked`. Installed release validation has no
open DevOps defect: stale-source branching, identity, installed checksum and
mode parity, framework-write integrity, doctor, and framework validation are
all execution-backed. The sole blocker is the concurrent protected-state/S10
mutation and moving downstream worktrees. Required owner: `bubbles.audit`.

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

---

## BUG-010 — adversarial resolver validates shadowed counts and substring-matches directive keys

- **Filed:** 2026-07-11
- **Status:** In Progress — the focused resolver fix is independently verified;
  broader IMP-020 S2 integration and certification remain open
- **Disposition:** both in-scope implementation findings are fixed and
  independently verified with current-session evidence. IMP-020 S2 remains
  open for its broader framework integration, finding reconciliation, and
  certification work
- **Discovered by:** IMP-020 S2 live three-sample adversarial run,
  `s2-live-invocation-01` / `sample-01.json`
- **Severity:** high — the resolver can reject a valid highest-priority sample
  count and can silently invent both canonical and deprecated count directives
  from unrelated words
- **Affects:** `bubbles/scripts/adversarial-resolve.sh` precedence validation
  and `directive_token`; regression coverage belongs in
  `bubbles/scripts/adversarial-resolve-selftest.sh`
- **Routing:** return to the IMP-020 orchestrator for S2 finding reconciliation
  and remaining integration/certification, then `bubbles.docs` and
  `bubbles.releases` as applicable; no implementation handoff remains

> **Source-repo artifact convention:** Gate G085 forbids persistent `specs/` in
> the Bubbles source checkout. This compact BUG-010 entry is therefore the full
> source-repo bug artifact: reproduction, evidence provenance, expected
> behavior, root cause, scenarios, change boundary, implementation/test plan,
> DoD, status, and routing. No `specs/` artifact is created for this bug.

### BUG-010 Summary

The IMP-020 S2 resolver promises one highest-wins chain for `samples`:
directive, then environment, then project config, then default. Two tightly
related parser/resolution defects violate that contract:

1. The script validates every populated count in every layer before selecting
   the effective layer. A valid `--samples 3` is therefore rejected when a
   shadowed lower-priority `BUBBLES_ADVERSARIAL_SAMPLES=0` exists, even though
   the environment value cannot win.
2. Free-form directive extraction searches for key text without identifier
   boundaries. `resamples: 7 compasses: 9` is misread as the exact keys
   `samples: 7` and `passes: 9`; the resolver returns seven samples and falsely
   reports use of the deprecated `passes` alias.

Both defects are at the same trust boundary: input tokens must first be
identified exactly and resolved by precedence, and only the selected effective
value may determine success or failure.

### Focused Fix Verification — Current Session

**Claim Source:** executed

**Command 1:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/adversarial-resolve-selftest.sh`

**Command 2:** `cd /Users/pkirsanov/Projects/bubbles && BUBBLES_ADVERSARIAL_SAMPLES=0 bash bubbles/scripts/adversarial-resolve.sh --repo-root /tmp --samples 3 && bash bubbles/scripts/adversarial-resolve.sh --repo-root /tmp --directive 'resamples: 7 compasses: 9' && bash bubbles/scripts/adversarial-resolve.sh --repo-root /tmp --directive 'my-samples: 7'`

**Exit Codes:** 0, 0

**Concise raw output from the independent run:**

```text
adversarial-resolve-selftest: 150 passed, 0 failed
PASS
mode=off
samples=3
sampleSemantics=same-runtime-correlated
teeth=warn
source=default
samplesSource=directive
deprecation=none
mode=off
samples=1
sampleSemantics=same-runtime-correlated
teeth=warn
source=default
samplesSource=default
deprecation=none
mode=off
samples=1
sampleSemantics=same-runtime-correlated
teeth=warn
source=default
samplesSource=default
deprecation=none
```

**Result:** PASS — the 150-assertion focused selftest has zero failures. In the
live probes, a shadowed invalid `BUBBLES_ADVERSARIAL_SAMPLES=0` no longer
rejects valid `--samples 3`, and both `resamples: 7 compasses: 9` and
`my-samples: 7` leave the resolver at `samples=1`, `samplesSource=default`, and
`deprecation=none`. This verifies the two BUG-010 implementation findings only;
it does not establish broader IMP-020 S2 integration, framework validation,
certification, release, propagation, or downstream installation.

### Live S2 Evidence And Reproduction — Before Fix

**Claim Source:** executed by the pre-existing IMP-020 S2 live invocation;
interpreted against current source in this documentation phase.

**Evidence record:** `/tmp/bubbles-imp020-s2-live/sample-01.json`, sample
`s2-live-01`, invocation `s2-live-invocation-01`, verdict `findings`. The record
marks both findings `blocking: true` and points to focused probes 3 and 4.
Sample 02 was clear; Sample 03 reported separate public-claim findings. BUG-010
accounts only for the two resolver findings from Sample 01.

**Rerun statement:** the two focused probes were **not rerun** during this
G085 documentation-only edit. The commands below encode the live probe inputs;
the observed contracts are transcribed from the live record and corroborated
by the current resolver control path. No post-fix output exists.

#### Finding 1 — shadowed invalid environment value rejects valid directive

```bash
cd /path/to/bubbles
BUBBLES_ADVERSARIAL_SAMPLES=0 \
  bash bubbles/scripts/adversarial-resolve.sh --samples 3
```

**Observed output/exit contract:** stdout is empty; stderr reports:

```text
adversarial-resolve: invalid BUBBLES_ADVERSARIAL_SAMPLES '0' (expected positive integer)
```

The process exits `1` (validation failure). The valid directive never reaches
the documented precedence result `samples=3` / `samplesSource=directive`.

#### Finding 2 — longer identifiers are accepted as directive keys

```bash
cd /path/to/bubbles
bash bubbles/scripts/adversarial-resolve.sh \
  --directive 'resamples: 7 compasses: 9'
```

**Observed discriminating output/exit contract:** the process exits `0`,
resolves `samples=7` from the directive layer, and reports deprecated-alias
metadata even though neither exact key was supplied:

```text
samples=7
samplesSource=directive
deprecation=passes-alias
```

Current source also emits the corresponding stderr warning
`DEPRECATED: passes alias used at layer(s): directive; use samples instead`.
That warning is itself false metadata for this input because `compasses` is not
the `passes` key.

### Confirmed Pre-Fix Root Cause

`bubbles/scripts/adversarial-resolve.sh` confirms both failure paths:

1. `validate_count` is called for directive samples/passes, environment
   samples/passes, and config samples/passes **before** `resolve_layer` chooses
   directive over environment over config over default. Validation therefore
   observes values that have already lost precedence.
2. `directive_token` runs an unbounded expression equivalent to
   `(${key})[[:space:]]*[:=]...`. For key `samples`, the match can begin in the
   middle of `resamples`; for key `passes`, it can begin in `compasses`.
   `head -n1` then turns each substring into a real directive value.
3. `adversarial-resolve-selftest.sh` proves valid precedence and invalid values
   only in isolation. It has no case where an invalid lower layer is shadowed
   by a valid higher layer, and no longer-identifier adversary for directive
   keys. The current positives therefore cannot detect either defect.

### BUG-010 Expected Behavior

- The resolver MUST select the effective value by the documented precedence
  chain before validating that effective value.
- A valid higher-priority value MUST not be rejected by an invalid value in a
  shadowed lower-priority layer.
- An invalid value that actually wins precedence MUST still exit `1` with the
  existing value-specific diagnostic. This fix is not permission to weaken
  fail-closed validation.
- Directive extraction MUST recognize exact `mode`, `adversarial`, `samples`,
  `passes`, and `teeth` keys only at token boundaries accepted by the free-form
  directive grammar.
- `resamples` and `compasses` MUST match neither `samples` nor `passes`. With no
  other count source, the input resolves `samples=1`,
  `samplesSource=default`, `deprecation=none`, and emits no alias warning.
- Exact `samples: N` and exact deprecated `passes: N` behavior, including
  canonical-samples-wins at the same layer, MUST remain compatible.
- Exit contracts remain closed: `0` resolved, `1` selected-value validation
  failure, and `2` usage error.

### Regression Scenarios

```gherkin
Feature: Exact adversarial sample resolution

  Scenario: A valid directive count shadows an invalid environment count
    Given BUBBLES_ADVERSARIAL_SAMPLES is 0
    And the per-run arguments contain --samples 3
    When adversarial-resolve selects and validates the effective sample count
    Then it exits 0
    And it emits samples=3
    And it emits samplesSource=directive
    And it does not validate the shadowed environment count as effective input

  Scenario: Longer identifiers do not become samples or passes directives
    Given no environment or project-config sample count is set
    And the free-form directive is "resamples: 7 compasses: 9"
    When adversarial-resolve extracts exact directive keys
    Then it exits 0
    And it emits samples=1
    And it emits samplesSource=default
    And it emits deprecation=none
    And it emits no deprecated passes-alias warning
```

### Change Boundary

**Authorized implementation surfaces:**

- `bubbles/scripts/adversarial-resolve.sh` — exact token matching and
  precedence-before-validation for count resolution.
- `bubbles/scripts/adversarial-resolve-selftest.sh` — the two exact regression
  cases plus anti-overcorrection controls.

**Excluded from this bug fix:** aggregator behavior/schema, sample dispatch,
red-team agent contracts, public terminology/docs, unrelated IMP-020 findings,
BUG-009, downstream installed copies, and any new `specs/` tree. Generated
release provenance remains a later `bubbles.releases` responsibility after the
source fix and tests are green; no managed downstream file may be hand-patched.

### Implementation Plan

1. Refactor count selection so each layer first chooses canonical `samples`
   over its same-layer `passes` alias, then the existing precedence chain
   chooses one effective count, and only that selected count is validated.
2. Preserve the selected layer/name in diagnostics so an invalid winning
   environment or config value still reports its existing specific label.
3. Make `directive_token` require portable, explicit key boundaries rather
   than substring matches; do not introduce GNU-only PCRE/lookbehind behavior.
4. Preserve exact-key compatibility, deprecation metadata, canonical output
   order, `same-runtime-correlated` semantics, and exits `0/1/2`.
5. Keep the patch minimal and canonical-source-only; do not mix in the other
   Sample 01/03 findings.

### Test Plan

1. `bubbles.implement` adds the two scenarios to
   `adversarial-resolve-selftest.sh` before changing production behavior and
   records that they fail for the exact pre-fix reasons.
2. Add precedence controls proving a selected invalid environment/config value
   still exits `1`, while valid directive-over-invalid-environment and
   environment-over-invalid-config combinations resolve successfully.
3. Add token controls proving exact `samples:` and exact `passes:` still work,
   same-layer canonical `samples` still wins, and `resamples`/`compasses` create
   neither a count nor deprecation metadata.
4. `bubbles.test` runs the production resolver through the focused shell
   selftest, scans the new cases for silent-pass bailout patterns, and runs the
   canonical framework validation command with full output.
5. Re-run the two live focused probes after the fix. IMP-020 S2 finding
   accounting remains open unless both post-fix contracts match Expected
   Behavior. API, browser/UI, datastore, load, and telemetry tests are not
   applicable to this pure shell resolver contract and must not be fabricated.

### Definition Of Done

- [ ] Pre-fix regression evidence shows both new behavior tests failing for
  the exact BUG-010 reasons.
- [x] Effective count precedence is selected before validation, without
  weakening validation of the selected value. Evidence: [focused fix
  verification](#focused-fix-verification--current-session).
- [x] Directive keys are matched exactly; `resamples` and `compasses` are not
  accepted as `samples` and `passes`. Evidence: [focused fix
  verification](#focused-fix-verification--current-session).
- [ ] Exact canonical and deprecated-alias compatibility controls pass.
- [ ] The focused resolver selftest passes with no silent-return or
  test-created-success bailout.
- [ ] Canonical framework validation passes with full execution evidence.
- [ ] The two live focused probes are rerun after the fix and produce the
  expected exit/output contracts.
- [ ] `bubbles.test` verifies all applicable regression and compatibility
  checks with no collateral failures.
- [ ] Both Sample 01 findings are accounted for one-to-one; IMP-020 S2 remains
  open for any other S2 blocker and cannot close while BUG-010 is unresolved.
- [ ] BUG-010 is marked fixed/verified only after implementation and test
  evidence exists; release/propagation is not inferred from source validation.

### Current Disposition And Handoff

BUG-010's two focused implementation findings are fixed and independently
verified by the current-session 150/0 selftest and live resolver probes above.
Only the two precisely matching implementation DoD items are checked. The
pre-fix-evidence, compatibility-control, broader framework-validation,
independent test-owner, full S2 accounting, certification, release,
propagation, and downstream items remain unchecked and unclaimed.

The next required owner is the IMP-020 orchestrator for one-to-one S2 finding
reconciliation and the remaining integration/certification chain. Route to
`bubbles.docs` for managed documentation reconciliation and to
`bubbles.releases` for generated release provenance/package work as applicable.
There is no remaining `bubbles.implement` handoff for these two findings.

---

## BUG-011 — adversarial aggregate counts duplicate invocation IDs as independent samples

- **Filed:** 2026-07-11
- **Status:** Reported — reproduced by the IMP-020 S2 post-fix adversarial
  sample; implementation and independent test verification are pending
- **Severity:** high — `expectedSamples` can be satisfied without the required
  number of distinct actual invocations, so correlated duplicate records can
  be reported as agreement
- **Affected:** `bubbles/scripts/adversarial-aggregate.sh`; regression coverage
  belongs only in `bubbles/scripts/adversarial-aggregate-selftest.sh`
- **Discovered by:** IMP-020 S2 post-fix sample
  `/tmp/bubbles-imp020-s2-postfix/sample-02.json`
- **Routing:** `bubbles.implement`, then `bubbles.test`; IMP-020 S2 cannot close
  while BUG-011 remains unresolved

> **Source-repo artifact convention:** Gate G085 forbids persistent `specs/` in
> the Bubbles source checkout. This compact BUG-011 entry is therefore the full
> source-repo bug artifact: evidence provenance, reproduction, expected
> behavior, root cause, scenarios, boundary, implementation/test plan, DoD,
> status, and routing. No `specs/` artifact is created for this bug.

### BUG-011 Summary And Live Evidence

`adversarial-aggregate.sh` enforces uniqueness of `sampleId`, but it does not
enforce uniqueness of `invocationId`. Two individually schema-valid records
can therefore carry distinct sample IDs while naming the same actual
invocation. The aggregator counts both files toward `expectedSamples` and can
emit `agreement-clear`, even though the N-sample contract was not backed by N
distinct invocations.

**Claim Source:** interpreted from live post-fix sample evidence
`/tmp/bubbles-imp020-s2-postfix/sample-02.json`.

The evidence record is sample `s2-postfix-02`, invocation
`s2-postfix-invocation-02`, verdict `findings`, with one blocking provenance
finding. It records a duplicate-invocation probe in which two schema-valid
records shared `invocationId` `same-runtime-invocation-01` and the aggregator
returned exit `0` with `agreement-clear`.

**Rerun statement:** the duplicate-invocation probe was **not rerun** while
filing BUG-011. The observed contract below is transcribed from the named live
evidence record; it is not claimed as current-session execution evidence.

### Exact Reproduction Shape — Before Fix

Supply exactly two schema-valid, completed, clear sample records. All required
schema and provenance fields remain valid; the discriminating identity fields
have this exact relationship:

```text
record A: sampleId=<distinct-sample-a>, invocationId=same-runtime-invocation-01
record B: sampleId=<distinct-sample-b>, invocationId=same-runtime-invocation-01
constraint: <distinct-sample-a> != <distinct-sample-b>
both: sampleSemantics=same-runtime-correlated, status=completed, verdict=clear,
      findings=[], and schema-valid runtime/model/tools provenance
```

Invoke the production boundary with the expected count equal to the file
count:

```bash
bash bubbles/scripts/adversarial-aggregate.sh --expected-samples 2 \
  <first-schema-valid-record.json> <second-schema-valid-record.json>
```

**Observed contract recorded by the live evidence:**

```text
exit=0
outcome=agreement-clear
actualSamples=2
```

The distinct `sampleId` values satisfy the only identity-uniqueness check, so
the shared `invocationId` does not prevent a successful agreement outcome.

### BUG-011 Expected Behavior

- Every accepted input record MUST represent a distinct `invocationId` as well
  as a distinct `sampleId`.
- Repeated `invocationId` values MUST fail closed with
  `outcome=aggregation-error` and a nonzero exit. Under the aggregator's
  existing closed exit contract, aggregation errors exit `2`.
- The structured error SHOULD identify a deterministic
  `duplicate-invocation-id` condition at path `invocationId`; an agreement
  outcome MUST NOT be emitted for that input set.
- Distinct schema-valid `sampleId` and `invocationId` values MUST retain the
  existing agreement behavior and canonical output ordering.
- File count alone MUST NOT satisfy `expectedSamples`; the accepted set must
  contain exactly that many distinct actual invocation IDs.

### Confirmed Root Cause

After schema validation, `adversarial-aggregate.sh` builds `sample_ids` and
uses `seen_ids` to emit `duplicate-sample-id` errors. It never builds or checks
an equivalent set of `invocationId` values. `invocationId` is validated only as
an individual required string and is later copied into `sampleMatrix`; it does
not participate in aggregate identity validation. Consequently, two files with
different sample IDs pass uniqueness and count checks even when both describe
the same invocation. The existing selftest covers duplicate `sampleId` with
different invocation IDs, but not the inverse adversary that exposes BUG-011.

### BUG-011 Regression Scenarios

```gherkin
Feature: Distinct invocations back adversarial sample agreement

  Scenario: Distinct sample IDs cannot hide a duplicate invocation ID
    Given two schema-valid completed clear records have distinct sample IDs
    And both records have invocationId "same-runtime-invocation-01"
    And expectedSamples is 2
    When adversarial-aggregate processes both records
    Then it exits nonzero with the aggregation-error contract
    And the error identifies the duplicate invocationId
    And it does not emit agreement-clear

  Scenario: Two genuinely distinct invocations can still agree clear
    Given two schema-valid completed clear records have distinct sample IDs
    And their invocation IDs are also distinct
    And expectedSamples is 2
    When adversarial-aggregate processes both records
    Then it exits 0 with agreement-clear
    And existing canonical ordering remains unchanged
```

### BUG-011 Change Boundary

**Authorized implementation surfaces only:**

- `bubbles/scripts/adversarial-aggregate.sh` — enforce invocation-ID
  uniqueness at the aggregate input boundary.
- `bubbles/scripts/adversarial-aggregate-selftest.sh` — add the exact
  adversarial regression and a distinct-invocation compatibility control.

**Excluded:** schemas, resolver, dispatcher, agent prompts, workflow registry,
documentation outside this BUG-011 entry, BUG-009, BUG-010, downstream copies,
and all unrelated IMP-020 findings. No fix is included in this filing.

### BUG-011 Implementation Plan

1. After successful per-record schema validation, collect `invocationId`
   values alongside `sampleId` values and detect duplicates deterministically.
2. Add a structured duplicate-invocation aggregation error without changing
   the existing duplicate-sample error, count, schema, finding-union, or output
   ordering contracts.
3. Ensure any duplicate invocation keeps the aggregate on the existing
   `aggregation-error` / exit-`2` path and can never reach agreement selection.
4. Keep the correction local to the aggregator; do not weaken schema
   validation or infer invocation identity from filenames or sample IDs.

### BUG-011 Test Plan

1. `bubbles.implement` first adds two fixtures with distinct `sampleId` values
   and the shared `invocationId` `same-runtime-invocation-01`, then records the
   focused regression failing because current source exits `0` with
   `agreement-clear`.
2. Implement the invocation-ID uniqueness check and assert exit `2`,
   `outcome=aggregation-error`, the duplicate-invocation error code/path, and
   absence of an agreement outcome for the exact adversarial pair.
3. Add a positive control with both identity fields distinct, plus input-order
   permutations proving deterministic output and no overcorrection.
4. `bubbles.test` independently runs the complete focused aggregator selftest,
   checks the new regression for silent-pass bailout patterns, and reruns the
   exact duplicate-invocation production probe.
5. Return the evidence to the IMP-020 S2 finding ledger. S2 remains open until
   implementation and independent test evidence account for this blocking
   finding one-to-one.

### BUG-011 Definition Of Done

- [ ] Pre-fix regression execution records the exact adversarial pair exiting
  `0` with `agreement-clear` before production source changes.
- [ ] Duplicate `invocationId` values produce structured
  `aggregation-error` output and a nonzero exit without changing duplicate
  `sampleId` behavior.
- [ ] The adversarial regression would fail if invocation-ID uniqueness were
  removed and contains no silent-pass bailout.
- [ ] Distinct-invocation compatibility and input-order controls pass.
- [ ] The complete focused aggregator selftest passes after the fix.
- [ ] `bubbles.test` independently reruns the focused selftest and exact
  production probe with current-session evidence.
- [ ] No file outside the aggregator and its selftest changes for the fix.
- [ ] The IMP-020 S2 finding is reconciled one-to-one and S2 remains open for
  any other unresolved blocker.
- [ ] BUG-011 is marked fixed or verified only after implementation and test
  evidence exists; no release, propagation, or downstream state is inferred.

### BUG-011 Current Disposition And Handoff

BUG-011 is documented but unfixed. All DoD items remain unchecked, no
post-filing rerun or fix is claimed, and IMP-020 S2 cannot close. The next
required owner is `bubbles.implement` for the bounded aggregator/selftest
change. After implementation, route to `bubbles.test` for independent focused
execution and return the result to the IMP-020 orchestrator for S2 finding
reconciliation.

---

## BUG-012 — G085 first-adoption deadlock blocks the first downstream feature

- **Filed:** 2026-07-12
- **Status:** Implementation complete — focused and adversarial regressions, full framework validation, and release readiness are green; independent test verification and certification remain open
- **Severity:** high — a newly adopted downstream repository cannot produce the first done-spec evidence G085 requires
- **Affected:** `bubbles/scripts/framework-dogfood-guard.sh`, its hermetic selftest, persistent G085 regression, and direct G085 documentation
- **Reported by:** Research Lab onboarding
- **Routing:** `bubbles.design` → `bubbles.plan` → `bubbles.implement` → `bubbles.test` → `bubbles.validate` → `bubbles.audit` / `bubbles.docs`

> **Source-repo artifact convention:** Gate G085 forbids persistent `specs/` in
> the Bubbles source checkout. The complete BUG-012 packet therefore lives at
> `improvements/BUG-012-g085-first-adoption-deadlock/` with `bug.md`, `spec.md`,
> `design.md`, `scopes.md`, `report.md`, `state.json`, `uservalidation.md`, and
> `scenario-manifest.json`.

### Reproduction And Root Cause

The canonical guard was executed against Research Lab and returned G085 exit
`1` with two numbered `not_started` specs and `doneCount=0`. Research Lab is a
non-shallow Git checkout with zero reachable commits touching numbered
top-level spec state files. The downstream guard has no adoption-lifecycle
branch: every `DONE_COUNT < 1` repository is rejected, so the first transition
requires evidence that only that transition can create.

Install provenance cannot independently solve the classification because
`.install-source.json::installedAt` is rewritten on refresh. The packet routes
a fail-closed history discriminator for specialist confirmation: current done
evidence passes normally; zero current done plus historical done evidence
fails; zero current and historical done evidence in a full non-shallow history
is first adoption; shallow/missing history fails closed.

### Implementation Progress

The canonical guard now preserves the current-done fast path and grants
`G085-FIRST-ADOPTION` only after complete exact-root, non-shallow,
non-partial, all-ref history proves that no numbered top-level done-state blob
is reachable. Changed, deleted, and alternate-ref historical done evidence
remains established; missing, shallow, partial, malformed, and failed history
fails closed with distinct diagnostics.

The focused production-guard selftest covers both partial-history metadata
branches independently and verifies delegated Check 26 guidance names both
valid downstream pass paths. The persistent regression preserves the
identical-current-state adversarial pair and an effective shallow clone. Full
framework validation and release readiness are green and recorded in the
BUG-012 packet. Independent test verification and validate-owned certification
remain pending; no downstream managed copy is edited directly.

### Research Lab Propagation Requirement

After upstream specialist delivery and validation, Research Lab must consume
the fix through `bash .github/bubbles/scripts/cli.sh upgrade`: first a dry run,
then upgrade, doctor, framework-write-guard, installed G085, and the original
spec guard. A local-source rehearsal uses the same sequence with
`--local-source ../bubbles`; a clean published rollout omits that flag. Direct
edits or manual copies into Research Lab `.github/bubbles/**` are forbidden.

---

## BUG-013 — G028 Scan 2B misclassifies sensitive client storage

- **Filed:** 2026-07-12
- **Status:** Implementation complete with focused regression green; test and validate certification pending
- **Severity:** high — a blocking security gate has a durable-credential false negative, cache/cleanup false positives, no narrow exact session-provider classification, and a macOS-inoperable managed selftest
- **Affected:** `implementation-reality-scan.sh` Scan 2B, its managed selftest, project config contract, persistent regression, and direct G028 registry/docs
- **Reported by:** Research Lab Feature 001 transition
- **Routing:** `bubbles.design` → `bubbles.plan` → `bubbles.implement` → `bubbles.test` → `bubbles.docs` → `bubbles.validate`

> **Source-repo artifact convention:** G085 forbids persistent `specs/` in the
> Bubbles source checkout. The complete BUG-013 packet lives at
> `improvements/BUG-013-g028-sensitive-client-storage-classification/` with all
> required bug/control-plane artifacts and a machine-readable test handoff.

### Reproduction And Root Cause

The canonical scanner executed against a hermetic five-case JavaScript fixture.
It missed `localStorage.setItem(KEY_STORE, ...)`, flagged exact and unknown
session providers identically, and falsely flagged a market-cache write whose
inline comment names auth/payment terms plus an auth-token `removeItem` cleanup
line. Against Research Lab it reported nine mixed findings, including comment,
cache, and scrubbed-object rewrites, while missing the separate
`KEY_STORE = "rlApiKeys"` durable path.

Scan 2B is six line-local regexes: it does not resolve constants, parse storage
operations, strip inline comments, classify values/providers, or consult an
exact project config tuple. Its reverse-order expression can match cleanup and
comment text. The managed selftest has no Scan 2B fixtures and invokes raw
`timeout 180` at three call sites; direct execution on macOS fails all four
existing cases before the scanner runs even though `guard-lib.sh` already ships
`bubbles_run_with_timeout`.

### Required Contract

Credential-bearing durable storage remains always blocked. `sessionStorage` is
default-deny and may pass only for one exact normalized path/key/provider tuple
explicitly classified as third-party market data, low privilege, and same-tab.
Unknown/dynamic providers and malformed or unevaluable config fail closed.
Auth/session/bearer/refresh/payment secret classes cannot be approved. Semantic
detection must follow bounded constants/aliases, distinguish persistence from
remove/clear/proven scrub, and ignore comment-only vocabulary and untainted
market caches. Adversarial hermetic pairs and a persistent E2E regression bind
each discriminator; the selftest must use the portable timeout helper.

### Implementation Progress

The canonical scanner now delegates Scan 2B to an install-managed bounded
classifier, the managed selftest owns the semantic/config/portable-timeout
matrix, and `tests/regression/test_24_g028_sensitive_client_storage.sh` executes
the production scanner across every planned adversarial pair. The post-fix
persistent run reports `57 passed, 0 failed`; regression integrity reports one
adversarial file and zero violations or warnings. Exact project-config and G028
registry contracts are synchronized in canonical source.

Full framework validation, install provenance, release readiness, execution
evidence reconciliation, and validate-owned certification are not inferred from
those focused results. No downstream file was edited or upgraded.

---

## BUG-014 - adversarial resolver accepts ambiguous and out-of-contract posture inputs

- **Filed:** 2026-07-14
- **Status:** In Progress - BUG014-F1 through BUG014-F5 remain repaired history
  and current behavior. Routed `bubbles.harden` evidence exposed unresolved
  extensions of BUG014-F6 and BUG014-F7. BUG014-F8 has implementation plus
  focused and routed hardening evidence, but remains nonterminal pending the
  independent lifecycle after the F6/F7 repair. This planning recovery ran no
  resolver test or hardening probe
- **Disposition:** exactly eight resolver findings are in scope. BUG014-F1
  through BUG014-F5 retain their repaired history and current behavior;
  BUG014-F6 and BUG014-F7 are the active unresolved fail-closed infrastructure
  defects; BUG014-F8 retains its implementation and evidence history without a
  terminal disposition. BUG-014 is not fixed, closed, tested on the new F6/F7
  cases, hardening-clean, stabilized, validated, audited, documented for
  release, or certified
- **Severity:** high - malformed or ambiguous posture input can silently select
  a different mode, sample count, or enforcement strength; an unbounded count
  can request excessive top-level adversarial invocations; parser-record
  consumption failure can publish a default posture with raw path-dependent
  shell diagnostics; and malformed successful config-parser output can be
  trusted as scalar presence metadata
- **Affected:** `bubbles/scripts/adversarial-resolve.sh`; regression coverage
  belongs in `bubbles/scripts/adversarial-resolve-selftest.sh`
- **Evidence:** historical before-fix records
  `/tmp/bubbles-imp020-s2-current-sample-01.json` and
  `/tmp/bubbles-imp020-s2-current-sample-03.json`, prior focused execution
  records (`463/0` and the later test-owner-reported `494/0`), current source
  inspection, and routed `bubbles.harden` evidence of `594 passed, 0 failed`
  plus a `139`-case / `510`-check production-path matrix with `507` passing and
  `3` failing checks. Those executions were not run by this planning recovery
- **Routing:** `bubbles.implement` -> `bubbles.test` -> rerun
  `bubbles.stabilize` hardening -> `bubbles.validate` -> `bubbles.audit` /
  `bubbles.docs` -> framework/release checks -> IMP-020 S2 reconciliation

> **Source-repo artifact convention:** Gate G085 forbids persistent `specs/` in
> the Bubbles source checkout. This compact BUG-014 entry is the complete
> source-repo artifact: status, evidence provenance, reproduction, expected
> behavior, root cause, scenarios, change boundary, implementation/test plan,
> evidence-scoped DoD, and routing. This reconciliation changes only `BUGS.md`;
> it observes but does not author the current source/test repair, and it creates
> no `specs/` artifact.

### BUG-014 Summary And Exact Finding Set

BUG-014 accounts for exactly these eight resolver findings:

F1-F5 retain the defect identities and before-fix observations that explain
their repairs. F6 and F7 are the current unresolved source defects. F8 retains
its defect identity, implementation, and routed evidence while remaining
nonterminal until independent lifecycle completion.

1. **BUG014-F1 - malformed free-form values are prefix-parsed or dropped.**
   `samples: 2.5` becomes `samples=2`; `mode: on-call` becomes `mode=on`;
   `teeth: blocking-ish` becomes `teeth=blocking`; and `samples: -2` is
   discarded so the resolver reports the default `samples=1` instead of
   rejecting the selected malformed value.
2. **BUG014-F2 - duplicate same-layer inputs are order-dependent.** Repeated
   `--directive`, `--mode`, and `--teeth` options silently overwrite earlier
   values, while the `adversarial` / `mode` free-form synonyms silently select
   the first match. Equivalent ambiguity therefore resolves differently based
   on argument or token order instead of being rejected.
3. **BUG014-F3 - the sample count ignores its configured maximum.** The
   resolver accepts `6` and `1000000000`, although
   `bubbles/workflows.yaml::executionOptions.optionalWorkflowTags.samples`
   declares `min: 1` and `max: 5`.
4. **BUG014-F4 - an explicit empty canonical count is treated as absent.**
   `--samples ''` resolves `samples=1` with `samplesSource=default` rather than
   failing validation for the explicitly supplied invalid value.
5. **BUG014-F5 - historical long-whitespace parsing scaled poorly.** Prior
   hardening measured `16,395B=224ms`, `32,779B=623ms`, `65,547B=1,841ms`,
   `98,315B=3,533ms`, and `131,083B=6,285ms`; its 128 KiB watchdog probe timed
   out at 5 seconds with exit `124`. Current source no longer follows that
   repeated-parser path: `parse_directive` writes one `DIRECTIVE_RECORD`, and
   the current selftest contains one-AWK-invocation and 128 KiB regressions.
6. **BUG014-F6 - directive parser-record production or consumption failure can
  be swallowed.** The historical `directive_token_count` pipeline ended in
  `|| true`; current source now fails closed for `mktemp` failure, AWK failure,
  and malformed record keys. However, routed hardening showed that after AWK
  successfully writes `DIRECTIVE_RECORD`, making that path absent or
  unreadable before the shell consumes it causes the current
  `if ! while ... done < "$DIRECTIVE_RECORD"` form to emit raw path-dependent
  shell stderr, return exit `0`, and publish the default `samples=1` posture.
  Missing, unreadable, non-regular, malformed, and failed record reads are all
  one unresolved extension of BUG014-F6, not additional findings.
7. **BUG014-F7 - successful config-parser output shape and tag semantics are
  unvalidated.** Current source checks nonzero status for all eight required
  `yq` value/tag queries and routed hardening confirmed that nonzero failures,
  partial stdout, and raw stderr fail closed. A `yq` command that exits `0`
  with malformed multi-line tag output is nevertheless accepted for all four
  fields because successful output cardinality, scalar shape, allowed tags,
  and tag/value consistency are not validated. Selected malformed values may
  fail later value validation, but malformed tags can still become trusted
  presence and deprecated-alias metadata. This is an extension of BUG014-F7,
  not a ninth finding.
8. **BUG014-F8 - parser-record cleanup must participate in the success
  decision.** Current source explicitly removes `DIRECTIVE_RECORD` before
  posture stdout, exits `2` on success-path removal failure, and preserves an
  already-nonzero validation or parser exit through the EXIT trap. The current
  selftest has valid, validation, parser, and normal-path cleanup cases, and
  routed hardening found no success stdout or residue leak under its normal and
  symlink-like disposable `TMPDIR` controls. F8 is implemented and evidenced,
  but remains nonterminal pending independent lifecycle completion after the
  active F6/F7 repair.

The other findings in Sample 03 concern package installation, managed-mode
documentation, and BUG-011 status. They are outside BUG-014 and are not
duplicated or dispositioned here.

### Historical Evidence Provenance And Before-Fix Reproduction

**Claim Source:** interpreted

This filing read the two existing evidence records and the current
`adversarial-resolve.sh` / `adversarial-resolve-selftest.sh` sources. It did
**not** rerun any resolver probe or test. The commands and observations below
are transcribed from the named records; they are prior execution evidence, not
current-session execution claims.

#### Sample 01

- **Exact record:** `/tmp/bubbles-imp020-s2-current-sample-01.json`
- **Sample ID:** `imp020-s2-current-01`
- **Invocation ID:** `imp020-s2-current-invocation-01`
- **Invoked at:** `2026-07-14T19:27:22Z`
- **Source revision recorded by the probes:**
  `9b785d7da7554082cfe0232998ef72cc99637087`
- **Provenance qualification:** runtime and model identity are `unverified`;
  the tool inventory is `self-reported`. The record does not claim model
  independence.

The record names these resolver invocations and observed contracts:

```bash
bash bubbles/scripts/adversarial-resolve.sh \
  --directive 'adversarial: on samples: 2.5 teeth: blocking'

bash bubbles/scripts/adversarial-resolve.sh \
  --directive 'mode: on-call samples: 1 teeth: blocking-ish'

bash bubbles/scripts/adversarial-resolve.sh \
  --directive 'samples: -2'

bash bubbles/scripts/adversarial-resolve.sh \
  --directive 'samples: 2' --directive 'samples: 3'

bash bubbles/scripts/adversarial-resolve.sh --mode on --mode off
bash bubbles/scripts/adversarial-resolve.sh --teeth blocking --teeth warn

bash bubbles/scripts/adversarial-resolve.sh \
  --directive 'adversarial: on mode: off'

bash bubbles/scripts/adversarial-resolve.sh --samples 5
bash bubbles/scripts/adversarial-resolve.sh --samples 6
bash bubbles/scripts/adversarial-resolve.sh \
  --mode on --samples 1000000000 --teeth blocking
```

**Observed by Sample 01:** every command exits `0`. The malformed values resolve
as `samples=2`, `mode=on`, `teeth=blocking`, and default `samples=1`
respectively. Repeated directives resolve `samples=3`; repeated mode resolves
`mode=off`; repeated teeth resolves `teeth=warn`; conflicting
`adversarial: on mode: off` resolves `mode=on`. Counts `5`, `6`, and
`1000000000` are all accepted.

#### Sample 03

- **Exact record:** `/tmp/bubbles-imp020-s2-current-sample-03.json`
- **Sample ID:** `imp020-s2-current-03`
- **Invocation ID:** `imp020-s2-current-invocation-03`
- **Invoked at:** `2026-07-14T19:37:55Z`
- **Source revision recorded by the probe:**
  `9b785d7da7554082cfe0232998ef72cc99637087`
- **Provenance qualification:** runtime and model identity are `unverified`;
  the tool inventory is `self-reported`. No distinct-runtime or distinct-model
  claim is made.

The record preserves the exact empty-value probe:

```bash
bash bubbles/scripts/adversarial-resolve.sh \
  --repo-root /tmp/bubbles-imp020-s2-current-empty \
  --mode on --samples '' --teeth blocking
```

**Observed by Sample 03:** exit `0` with `samples=1`,
`samplesSource=default`, and `deprecation=none`. The same record reports that
the focused resolver selftest then had `150 passed, 0 failed` and no explicit
empty-value case; BUG-014 does not recast that prior green result as coverage of
this missing contract.

### BUG-014 Historical Focused Evidence

**Claim Source:** interpreted (prior execution records; not rerun in this
planning recovery)

The following commands were executed by a prior BUG-014 reconciliation against
the then-current worktree on 2026-07-15. Each recorded exit code was `0`. This
planning recovery preserves the transcript but does not promote it into
current-session evidence:

1. `bash bubbles/scripts/adversarial-resolve-selftest.sh`
2. `bash -n bubbles/scripts/adversarial-resolve.sh bubbles/scripts/adversarial-resolve-selftest.sh`
3. `shellcheck bubbles/scripts/adversarial-resolve.sh bubbles/scripts/adversarial-resolve-selftest.sh`
4. `bash bubbles/scripts/regression-quality-guard.sh --bugfix bubbles/scripts/adversarial-resolve-selftest.sh`
5. `git diff --check -- bubbles/scripts/adversarial-resolve.sh bubbles/scripts/adversarial-resolve-selftest.sh BUGS.md`

The single home-directory value is rendered as `~/Projects/bubbles` below per
the repository evidence PII rule; all other output lines are the observed
focused output.

```text
BUG014_FOCUSED_EVIDENCE_BEGIN
$ bash bubbles/scripts/adversarial-resolve-selftest.sh
adversarial-resolve-selftest: 463 passed, 0 failed
PASS
SELFTEST_EXIT=0
$ bash -n bubbles/scripts/adversarial-resolve.sh bubbles/scripts/adversarial-resolve-selftest.sh
BASH_N_EXIT=0
$ shellcheck bubbles/scripts/adversarial-resolve.sh bubbles/scripts/adversarial-resolve-selftest.sh
SHELLCHECK_EXIT=0
$ bash bubbles/scripts/regression-quality-guard.sh --bugfix bubbles/scripts/adversarial-resolve-selftest.sh
============================================================
  BUBBLES REGRESSION QUALITY GUARD
  Repo: ~/Projects/bubbles
  Timestamp: 2026-07-15T15:49:34Z
  Bugfix mode: true
============================================================

ℹ️  Scanning bubbles/scripts/adversarial-resolve-selftest.sh
✅ Adversarial signal detected in bubbles/scripts/adversarial-resolve-selftest.sh

============================================================
  REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
  Files scanned: 1
  Files with adversarial signals: 1
============================================================
REGRESSION_QUALITY_EXIT=0
$ git diff --check -- bubbles/scripts/adversarial-resolve.sh bubbles/scripts/adversarial-resolve-selftest.sh BUGS.md
SCOPED_DIFF_CHECK_EXIT=0
BUG014_FOCUSED_EVIDENCE_END
```

A later prior `bubbles.test` owner report recorded
`adversarial-resolve-selftest: 494 passed, 0 failed` for the then-current
F1-F6 source/test repair. The current selftest bytes retain that matrix:
the protected F1-F4/BUG-010 matrix reaches `463:0`, the matrix-preservation
assertion is itself one pass, and the F5/F6 parser-failure, parse-once,
128 KiB, deterministic-replay, and cleanup assertions follow. This planning
recovery did not execute the selftest or reopen that test owner's raw terminal
transcript. The `494/0` result is therefore historical evidence for the former
F6 AWK-failure contract only; it provides no evidence for the newly routed F6
record-consumption extension, F7 successful-output shape, or F8's later
implementation.

### BUG-014 Historical Stabilize Evidence For F5/F6

**Claim Source:** interpreted (completed prior hardening; not rerun here)

The observations in this subsection were executed by the completed
`bubbles.stabilize` hardening phase. This BUGS.md reconciliation transcribes
that evidence; it did not rerun the probes and does not present them as
current-session execution.

| Long-whitespace directive size | Observed elapsed time |
| ---: | ---: |
| 16,395 bytes | 224 ms |
| 32,779 bytes | 623 ms |
| 65,547 bytes | 1,841 ms |
| 98,315 bytes | 3,533 ms |
| 131,083 bytes | 6,285 ms |

The completed hardening evidence also records a 128 KiB probe stopped by its
5-second watchdog with exit `124`. Its parser fault-injection probe supplied
directive `samples:0`, forced AWK failure, and observed resolver exit `0` plus
default posture fields `samples=1` and `deprecation=none`.

**Claim Source:** interpreted

The elapsed-time progression and timeout establish a resource-growth defect
for the former accepted long-whitespace path, but they do not by themselves
prove a formal complexity class. Source at the time repeatedly scanned the
directive and normalized parser/count failure into absence; those observations
ground the historical F5/F6 causes. Current bytes supersede the former repeated
parser and swallowed AWK-failure paths with one `parse_directive` call, explicit
production-parser failure, one private record, and persistent F5/F6 assertions.
That historical hardening run was non-clean; it is not a current hardening
verdict and does not cover the later F6 record-consumption or F7 output-shape
counterexamples.

#### Routed Hardening Evidence For The Current Eight-Finding Model

**Claim Source:** interpreted (executed by `bubbles.harden`; not rerun here)

The routed hardening owner reported an unchanged source-hash set, a full
focused selftest result of `594 passed, 0 failed`, and a disposable
production-path matrix of `139 cases`, `510 checks`, `507 passed`, and
`3 failed`. F1-F5 and F8 held. The three failed checks are accounted for by the
two existing finding identities: BUG014-F6 allowed a post-AWK record-consumption
fault to emit raw path-dependent shell stderr and return a default posture;
BUG014-F7 accepted successful malformed multi-line tag output for each field.
Nonzero failures for all eight `yq` calls, including partial stdout and raw
stderr, failed closed. AWK failure, `mktemp` failure, malformed record content,
and the F8 valid/validation/parser/config/duplicate-token cleanup paths also
failed closed. No success stdout leak or normal/symlink-like disposable
`TMPDIR` residue was reported for F8.

This is routed prior execution evidence, not work performed by this planning
recovery. The non-clean `507/510` matrix activates F6 and F7; it does not
establish a current repair, a clean hardening verdict, independent lifecycle
completion for F8, or IMP-020 S2 completion.

### BUG-014 Expected Behavior

- A recognized free-form key MUST validate its complete supplied lexeme. It
  MUST NOT accept an alphanumeric prefix or disappear because the first value
  character is punctuation. Thus `2.5`, `on-call`, `blocking-ish`, and `-2`
  are invalid selected values and fail closed.
- Repeating `--directive`, `--mode`, or `--teeth` in one invocation MUST be a
  usage error. Supplying both `adversarial` and `mode` tokens in one free-form
  directive MUST be the same logical-field ambiguity and MUST also be rejected.
- Duplicate-input rejection MUST occur before a partial resolved posture is
  emitted. The documented canonical-`samples`-over-deprecated-`passes`
  compatibility remains a separate, explicit alias rule and is not widened by
  this bug.
- Every selected sample count, regardless of directive, environment, config,
  or deprecated-alias origin, MUST be an integer in the closed range `1..5`,
  matching the authoritative `workflows.yaml` execution-option contract.
- An explicitly supplied empty `--samples` value MUST remain distinguishable
  from an omitted option and fail selected-value validation. Only true absence
  may fall through precedence to config or the default.
- Directive parsing MUST have an explicit resource contract. Accepted input
  MUST use the current one-parse record path or an equivalently bounded design;
  an approved over-limit input contract, if ever introduced, MUST fail nonzero
  without posture stdout before parser invocation.
- One parse MUST produce the logical token set used for duplicate detection,
  presence, and value extraction. The current parse-once behavior and bounded
  128 KiB production-path regression are protected anti-regression contracts.
- Every parser-record production and consumption operation MUST be checked
  explicitly. `mktemp` failure, AWK failure, a missing or unlinked record, an
  unreadable record, a non-regular record, malformed record shape or key, and
  any failed record read MUST exit `2`, emit exactly empty stdout, suppress raw
  shell/tool/path diagnostics, and emit exactly the stable class
  `adversarial-resolve: directive parser failed` on stderr.
- The repair MUST check the record-consumption operation itself and MUST NOT
  infer successful consumption from a compound `while`/redirection status.
  Parse-once remains mandatory. A truly empty directive remains a successful
  empty record, while a valid directive remains a successful single parse.
  Every failure and control path must leave zero resolver-owned record residue
  whenever removal is possible; the test harness owns deterministic cleanup of
  any deliberately non-removable fixture.
- If a config file exists and `yq` is available, failure of any one of the
  eight required value/tag queries MUST exit `2`, emit no posture stdout, and
  emit the stable diagnostic class `adversarial-resolve: config parser failed`.
  Empty output from a failed query MUST NOT be interpreted as null, absence, or
  a valid empty value.
- Successful `yq` status is necessary but insufficient. Every value query MUST
  yield exactly one scalar line. Embedded LF, embedded or trailing CR,
  zero-line output, or collection-shaped output is a config parser failure;
  an empty scalar line is valid output shape only when its paired tag is
  exactly `!!str`, after which ordinary selected-value validation still
  applies.
- Every tag query MUST yield exactly one allowed tag line for its field:
  `mode` and `teeth` allow only `!!null` or `!!str`; `samples` and deprecated
  `passes` allow only `!!null`, `!!str`, or `!!int`. This closed set preserves
  quoted numeric compatibility and explicit empty strings. Map, sequence,
  boolean, float, timestamp, custom, unknown, empty, and multi-line tags MUST
  fail as config parser errors.
- Tag/value consistency MUST be explicit: `!!null` denotes absence and must
  not carry a non-null value; a permitted non-null tag denotes presence;
  `!!int` must carry one integer scalar line; and `!!str` may carry one empty or
  non-empty scalar line. A contradiction MUST exit `2` with empty stdout and
  only `adversarial-resolve: config parser failed`, never raw `yq` output.
- Config inspection is integrity-sensitive even when directive or environment
  input would win precedence. A higher-precedence posture MUST NOT turn failed
  config inspection into success because config presence and deprecated-alias
  metadata cannot then be trusted.
- Existing missing-`yq` compatibility remains distinct: when no `yq` command is
  available, the resolver MUST retain its warning-and-skip behavior and may
  resolve from directive, environment, or default. F7 applies when the selected
  available parser starts but a required query fails or returns malformed
  successful output.
- Parser-record removal MUST complete before successful posture bytes become
  externally visible, or the resolver MUST use an equivalent atomic design.
  Cleanup failure after an otherwise valid resolution MUST exit `2`, emit no
  posture stdout, and emit the stable diagnostic class
  `adversarial-resolve: directive parser record cleanup failed`; it MUST never
  be reported as a valid resolution.
- A cleanup failure encountered while another parser or validation path is
  already nonzero MUST remain nonzero and preserve the controlling failure
  class: selected-value validation remains exit `1`, while parser/config/usage
  infrastructure remains exit `2`. Cleanup may add its stable diagnostic but
  MUST NOT convert failure to success or emit a posture.
- Existing directive > environment > config > default precedence, exact key
  boundaries fixed by BUG-010, canonical output ordering,
  `sampleSemantics=same-runtime-correlated`, deprecation metadata, and exit
  classes remain compatible: invalid selected values exit `1`; duplicate,
  structurally ambiguous, parser/config, and success-path cleanup failures exit
  `2`; valid fully cleaned resolution exits `0`.

### BUG-014 Confirmed Root Cause, Prior Repair, And Hardening Gaps

**Claim Source:** interpreted

The F1-F4 cause statements below are historical pre-fix causes reconstructed
from the prior evidence and original BUG-014 analysis. They do not describe the
current resolver or selftest as still broken for those four findings. F5/F6
history is retained separately from the current F6/F7 gaps and F8 lifecycle.

#### Historical Pre-Fix Cause

1. The former directive parser advanced a value cursor only across
  `[A-Za-z0-9]`. It emitted valid-looking prefixes before `.5`, `-call`, and
  `-ish`, while a leading `-` produced no token, making malformed selected
  values indistinguishable from absence.
2. The former argument loop did not retain presence for every repeatable field.
  Repeated `--directive`, `--mode`, and `--teeth` values therefore overwrote
  earlier values, while `adversarial` and `mode` were counted separately even
  though resolution treated them as one logical mode field.
3. The former count validation accepted any positive decimal integer and did
  not enforce the `workflows.yaml` maximum of `5`.
4. The former precedence path used empty-string fallback semantics, so an
  explicitly present empty canonical value could fall through as if omitted.
5. The former focused selftest omitted the malformed-lexeme, duplicate logical
  input, upper-bound, and explicit-empty cases and positively accepted counts
  above the registry maximum.

#### Current Repair Observed In Source And Focused Tests

1. **Full-lexeme validation:** `parse_directive` now retains the complete
  non-whitespace lexeme after a recognized exact key and separator. Decimal,
  signed, hyphen-suffixed, and delimiter-shaped values reach field validation
  intact instead of being prefix-parsed or dropped.
2. **Duplicate logical input rejection:** explicit seen bits reject repeated
  `--directive`, `--mode`, `--samples`, `--passes`, and `--teeth` flags, while
  `adversarial|mode` is counted as one logical directive field. Both ordering
  permutations are covered and ambiguity exits without a partial posture.
3. **`1..5` bounds:** `validate_count` accepts only one digit in the closed
  range `1` through `5`; focused cases exercise canonical and deprecated count
  inputs through directive flags/tokens, environment, and config.
4. **Explicit presence including empty values:** flag seen bits, environment
  existence checks, directive token counts, and config tag checks distinguish
  empty selected values from omitted or explicit-null values across layers.
5. **Cross-layer deprecated alias visibility:** deprecated `passes` presence is
  accumulated in deterministic directive, environment, and config order even
  when a higher-precedence canonical value shadows it; shadowed alias text
  remains metadata and is not incorrectly selected for validation.
6. **Bounded parse-once record:** `parse_directive` invokes AWK once, writes
  exact logical tokens to `DIRECTIVE_RECORD`, and populates in-memory counts and
  selected values from that record. The current selftest contains a one-AWK
  counter, a 128 KiB whitespace production-path case, and deterministic replay
  assertions.
7. **Parser production failure and normal cleanup:** parser-record creation and
  AWK failure route through `directive_parser_failed` with exit `2`. The
  current selftest injects AWK failure, expects empty stdout and the stable
  parser diagnostic, and checks normal success/failure paths leave zero parser
  records. The compound record-consumption form does not provide the same
  guarantee and is the active F6 extension.
8. **Checked config status and pre-output cleanup:** current source checks each
  of the eight `yq` command statuses and suppresses their raw stderr. It also
  calls `remove_directive_record` before the seven posture lines and retains
  the EXIT trap for nonzero paths. These changes implement the previously
  identified F7 nonzero-status and F8 cleanup paths, but do not validate
  successful `yq` output shape.

#### Historical F5/F6 Causes, Current F6/F7 Gaps, And F8 Lifecycle

- **Historical BUG014-F5 repeated full-directive parsing:** duplicate detection,
  presence checks, and extraction formerly restarted tokenization for each
  logical field. The current single `parse_directive` / `DIRECTIVE_RECORD` path
  replaces this cause.
- **Historical BUG014-F6 suppressed parser status:** the former count pipeline
  ended in `|| true` and printed a fallback zero. The current checked parser
  invocation and `directive_parser_failed` path replace AWK and `mktemp`
  suppression, but not post-production record-consumption failure. The
  `if ! while ... done < "$DIRECTIVE_RECORD"` condition relies on compound
  loop/redirection status; routed hardening demonstrated raw shell/path stderr,
  exit `0`, and default posture when the record becomes absent or unreadable
  before consumption.
- **Current BUG014-F7 trusts successful output shape:** all eight `yq` command
  substitutions now fail closed on nonzero status, but their successful stdout
  is accepted without line-count, CR/LF, scalar-kind, closed-tag, or tag/value
  consistency validation. Any non-`!!null` tag currently marks the field
  present, so a successful malformed tag can become trusted metadata even when
  the selected value later fails ordinary value validation.
- **BUG014-F8 implementation and pending lifecycle:** current source removes
  the parser record before stdout and makes failed removal nonzero. Current
  focused cases and routed hardening cover success, validation, parser, config,
  duplicate-token, normal, and symlink-like disposable `TMPDIR` paths. F8 is no
  longer an active implementation gap, but it remains nonterminal until the
  independent post-F6/F7 test, hardening, validation, and audit lifecycle is
  complete.

The prior `463/0` record supports the F1-F4 repair on its historical bytes. The
later test-owner-reported `494/0` record supports the former F1-F6 focused
matrix, but this planning recovery did not execute it. Routed hardening later
reported `594/0` focused and `507/510` production-path checks without source
hash changes: F1-F5 and F8 held, while F6 and F7 remained non-clean. None of
those prior results supplies a repair or green execution for the new F6/F7
cases, a clean hardening verdict, downstream/release evidence, or certification.

### Relationship To BUG-010

BUG-010 remains distinct and fixed. Its focused repair selects precedence before
validation and prevents longer identifiers such as `resamples` and `compasses`
from becoming exact directive keys. BUG-014 does not reopen either behavior.
BUG014-F1 through BUG014-F6 were exposed after exact keys could be identified:
they concern selected-value grammar, duplicate logical inputs, registry bounds,
explicit-empty presence, bounded parser work, and complete parser-record
production/consumption failure propagation. BUG014-F7 and BUG014-F8 remain
distinct config-inspection and parser-record-cleanup identities. The F6/F7
repair and preservation of F8 must not reopen BUG-010 or change its exact-key or
selected-precedence contract.

### BUG-014 Adversarial Regression Scenarios

```gherkin
Feature: Fail-closed adversarial resolver input contract

  Scenario Outline: Malformed free-form values cannot become valid prefixes or defaults
    Given the free-form directive contains <input>
    When adversarial-resolve parses and validates the selected logical field
    Then it exits 1 without emitting a resolved posture
    And it identifies the complete malformed value

    Examples:
      | input |
      | samples: 2.5 |
      | mode: on-call |
      | teeth: blocking-ish |
      | samples: -2 |

  Scenario Outline: Duplicate same-layer logical inputs are rejected
    Given one invocation contains <duplicates>
    When adversarial-resolve processes the directive layer
    Then it exits 2 without emitting a resolved posture
    And the diagnostic identifies an ambiguous duplicate logical field

    Examples:
      | duplicates |
      | --directive 'samples: 2' --directive 'samples: 3' |
      | --mode on --mode off |
      | --teeth blocking --teeth warn |
      | --directive 'adversarial: on mode: off' |

  Scenario Outline: Sample counts honor the workflows registry range
    Given the selected canonical sample count is <count>
    When adversarial-resolve validates it against the range 1 through 5
    Then the resolver <result>

    Examples:
      | count | result |
      | 1 | exits 0 with samples=1 |
      | 5 | exits 0 with samples=5 |
      | 6 | exits 1 without a resolved posture |
      | 1000000000 | exits 1 without a resolved posture |

  Scenario: Explicit empty samples is not an absent option
    Given the invocation contains --samples followed by an empty string value
    When adversarial-resolve applies directive precedence
    Then it exits 1 without a resolved posture
    But an invocation that omits every sample input still exits 0 with the
      documented default samples=1 and samplesSource=default

  Scenario: A 128 KiB whitespace directive stays on the parse-once path
    Given a recognized token is separated from its malformed selected value by
      exactly 128 KiB of whitespace
    When adversarial-resolve parses it through the production path
    Then it completes under the generous watchdog with the same exit and
      byte-identical stdout and stderr as the small control
    And tokenization invokes the parser exactly once per resolver invocation
    And no parser record remains after normal cleanup

  Scenario Outline: Parser-record production and consumption faults fail as one stable class
    Given directive parsing reaches the <operation> operation
    And the production-path harness introduces <fault>
    When adversarial-resolve produces and consumes its private parser record
    Then it exits 2
    And stdout is exactly empty
    And stderr is exactly adversarial-resolve: directive parser failed
    And stderr contains no raw shell, tool, permission, or temporary-path text
    And it emits neither samples=1 nor deprecation=none
    And resolver-owned parser-record residue is zero whenever removal is possible
    And the harness deterministically accounts for and removes any deliberately retained fixture

    Examples:
      | operation | fault |
      | record creation | mktemp exits nonzero |
      | record production | AWK exits nonzero |
      | record consumption | the completed record is unlinked before consumption |
      | record consumption | the completed regular record becomes unreadable |
      | record consumption | the completed path becomes a non-regular object |
      | record consumption | the explicit record read returns nonzero |
      | record validation | a successful producer writes malformed framing or an unknown key |

  Scenario Outline: Empty and valid directives remain parse-once controls
    Given the directive is <directive>
    When adversarial-resolve uses the production parser-record path
    Then the parser is invoked exactly once
    And the resolver <result>
    And stderr contains no raw parser-record diagnostic
    And no parser record remains

    Examples:
      | directive | result |
      | an empty string | exits 0 with the documented default posture |
      | mode: on samples: 3 teeth: blocking | exits 0 with canonical directive posture |

  Scenario Outline: An available config parser cannot fail open
    Given a project config file exists
    And the selected yq command is available
    And yq fails the required <query> inspection
    And a higher-precedence directive or environment value may also be present
    When adversarial-resolve inspects config before resolving posture
    Then it exits 2
    And stdout is empty
    And stderr contains the stable config-parser-failure diagnostic class
    And it emits neither a default nor a higher-precedence posture

    Examples:
      | query |
      | mode value |
      | mode tag |
      | samples value |
      | samples tag |
      | passes value |
      | passes tag |
      | teeth value |
      | teeth tag |

  Scenario Outline: Allowed config tags have closed scalar and presence semantics
    Given the <field> value query returns exactly one <value> scalar line
    And its tag query returns exactly one <tag> line
    When adversarial-resolve validates config parser output before precedence
    Then it treats the field as <presence>
    And the resolver <result>

    Examples:
      | field | value | tag | presence | result |
      | mode | null | !!null | absent | uses a higher layer or the default |
      | mode | on | !!str | present | may select mode=on |
      | teeth | null | !!null | absent | uses a higher layer or the default |
      | teeth | blocking | !!str | present | may select teeth=blocking |
      | samples | null | !!null | absent | uses a higher layer or samples=1 |
      | samples | 4 | !!str | present | supports quoted numeric samples=4 |
      | samples | 4 | !!int | present | supports integer samples=4 |
      | passes | null | !!null | absent | emits no config alias metadata |
      | passes | 4 | !!str | present | supports quoted numeric alias metadata |
      | passes | 4 | !!int | present | supports integer alias metadata |

  Scenario Outline: Explicit empty config strings preserve presence
    Given the <field> value query returns one empty scalar line
    And its tag query returns exactly !!str
    When adversarial-resolve validates output shape and applies precedence
    Then config parsing succeeds and the field is present
    And if selected, ordinary field validation exits 1 without posture stdout
    And it is not misclassified as absence or a config parser failure

    Examples:
      | field |
      | mode |
      | samples |
      | passes |
      | teeth |

  Scenario Outline: Successful malformed yq output fails closed
    Given yq exits 0 for the <field> config inspection
    And it returns <malformed-output>
    When adversarial-resolve validates successful query output
    Then it exits 2
    And stdout is exactly empty
    And stderr is exactly adversarial-resolve: config parser failed
    And no raw yq output is emitted
    And directive or environment precedence cannot bypass the failure

    Examples:
      | field | malformed-output |
      | mode | a multi-line tag |
      | samples | a multi-line tag |
      | passes | a multi-line tag |
      | teeth | a multi-line tag |
      | each value field | a multi-line scalar containing LF |
      | each value field | a scalar containing CR |
      | each field | !!map or !!seq tag output |
      | each field | !!bool, !!float, !!timestamp, or custom tag output |
      | each field | a null tag paired with a non-null value |
      | samples or passes | an integer tag paired with an empty or non-integer value |

  Scenario: Nonzero yq partial output remains a fail-closed control
    Given each of the eight required yq calls is failed in turn
    And the failed call may emit partial stdout and raw stderr
    When adversarial-resolve inspects config
    Then every invocation exits 2 with exactly empty stdout
    And stderr contains only the stable config-parser-failure class
    And no partial yq bytes, default posture, higher-precedence posture, or
      deprecated-alias metadata is published

  Scenario: Missing yq retains compatibility behavior
    Given a project config file exists
    And no yq command is available
    When adversarial-resolve evaluates directive, environment, and default layers
    Then it retains the documented warning-and-skip behavior
    And a valid non-config posture can still exit 0 in canonical output order

  Scenario: Success-path parser-record cleanup failure cannot publish posture
    Given directive parsing and posture validation would otherwise succeed
    And production-path fault injection makes removal of DIRECTIVE_RECORD fail
    When adversarial-resolve completes the resolution attempt
    Then it exits 2
    And stdout is empty
    And stderr contains the stable parser-record-cleanup-failure diagnostic class
    And the attempt is never reported as a valid resolution

  Scenario Outline: Cleanup cannot erase an existing failure
    Given the resolver is already on a <failure-path> path
    And parser-record removal also fails
    When the EXIT lifecycle completes
    Then it retains nonzero exit <exit-class>
    And stdout is empty
    And stderr retains the controlling failure diagnostic
    And stderr also diagnoses cleanup failure

    Examples:
      | failure-path | exit-class |
      | selected-value validation | 1 |
      | directive parser failure | 2 |
```

### BUG-014 Change Boundary

**Authorized implementation surfaces only:**

- `bubbles/scripts/adversarial-resolve.sh` - preserve F1-F5 and the implemented
  F8 pre-output cleanup; make parser-record consumption an explicitly checked
  F6 operation with stable diagnostics; and validate successful F7 value/tag
  output cardinality, scalar shape, closed tags, and tag/value consistency
  before applying precedence. Preserve missing-`yq` warning-and-skip behavior.
- `bubbles/scripts/adversarial-resolve-selftest.sh` - retain the complete
  F1-F5, F8, and BUG-010 matrices; add production-path F6 record-consumption
  faults and the complete F7 successful-output shape/tag matrix; assert exact
  exits, empty stdout, stable stderr classes, raw-diagnostic suppression,
  precedence non-bypass, and deterministic record lifecycle cleanup.

**Excluded:** adversarial aggregation/schema, red-team dispatch, agent or prompt
contracts, public documentation, BUG-010's fixed key/precedence behavior,
BUG-011, unrelated Sample 03 findings, generated release artifacts, downstream
installed copies, release/version/changelog surfaces, new helpers or package
dependencies, and every other IMP-020 scope. `BUGS.md` is planning-owned and is
the only file changed by this recovery. No generated, release, documentation,
downstream, resolver, or selftest file is changed in this planning slice.
Implementation remains confined to the same two files. Existing Bash facilities
are preferred for explicit status capture. If the resolver uses a standard
POSIX utility already guaranteed by the shell environment to make read status
observable, that is an existing runtime tool, not a new helper or package
dependency; its stderr and path details must still be suppressed behind the
stable F6 diagnostic.

### BUG-014 Implementation Record And Remaining Plan

1. The current source preserves option presence separately from option text for
  flags, exact directive tokens, environment values, and config values.
2. The current source rejects duplicate flags and duplicate logical directive
  fields before emitting a posture.
3. The current parser retains complete selected lexemes for validation and the
  current count validator enforces `1..5` at the effective selected layer.
4. The current selftest covers malformed values, ordering permutations,
  canonical/deprecated inputs across layers, empty-versus-absent behavior,
  compatibility controls, and adversarial signal.
5. Current source parses the free-form directive exactly once into
  `DIRECTIVE_RECORD`, checks `mktemp` and AWK, and installs an EXIT cleanup
  trap. Current tests contain parse-once, 128 KiB whitespace, AWK-failure,
  deterministic replay, and record-cleanup assertions.
6. Prior test-owner evidence reported `494 passed, 0 failed`. Routed hardening
  later reported `594 passed, 0 failed` plus `507/510` production-path checks
  with unchanged source hashes. This planning recovery executed neither run;
  the routed failures keep F6/F7 active and F8 nonterminal.
7. `bubbles.implement` must replace reliance on compound-loop/redirection
  status with an explicit checked parser-record consumption operation. Before
  accepting tokens it must reject a missing, unreadable, non-regular, malformed,
  or unsuccessfully read record through exit `2`, empty stdout, and exactly the
  stable parser diagnostic, with no raw shell/tool/path text. The record format
  must be validated as the expected allowed key plus tab-delimited value shape.
  Empty directive output remains a successful empty record; valid directives
  remain one parse.
8. `bubbles.implement` must centralize the eight `yq` calls behind a checked
  query/output contract that preserves command status and enough raw framing to
  distinguish zero lines, one empty line, one scalar line, multiple lines, and
  CR-bearing output. It must enforce the field-specific closed tag sets and
  tag/value consistency before setting any `CFG_*_PRESENT` bit. Successful
  malformed output and nonzero partial output both use the stable config parser
  failure class with no raw `yq` bytes.
9. `bubbles.implement` must preserve F8's pre-output removal and EXIT-trap
  behavior while integrating F6/F7. No F8 terminal claim follows from source
  presence or routed evidence; its focused cases remain mandatory regression
  controls through independent test and hardening.
10. `bubbles.implement` must add only the F6/F7 production-path cases in the
  authorized selftest. `bubbles.test` must execute the full focused matrix
  independently, then `bubbles.stabilize` must rerun complete eight-finding
  hardening before validation, audit/docs disposition, framework or release
  checks, or IMP-020 S2 reconciliation.

### BUG-014 Focused Test Record And Remaining Validation Plan

1. A prior reconciliation recorded `463 passed, 0 failed` for the F1-F4 matrix,
  plus syntax, ShellCheck, regression-quality, and scoped diff checks.
2. A later prior test-owner run reported `494 passed, 0 failed`. Routed
  hardening reported `594 passed, 0 failed` and `507/510` production checks.
  None was executed in this planning recovery; the latest matrix is explicitly
  non-clean for the F6/F7 extensions.
3. F6 must use production-path PATH shims or equivalent test-owned controls,
  without adding a production-only hook, to exercise: `mktemp` failure; AWK
  failure; post-AWK unlink; post-AWK unreadable and non-regular records;
  explicit record-read failure; malformed framing, unknown key, and incomplete
  records; an empty directive; and a valid multi-key parse. Every fault must
  assert exact exit `2`, exactly empty stdout, exactly the stable parser
  diagnostic, absence of raw shell/tool/path stderr, no default posture, and
  deterministic zero residue or test-owned cleanup of intentionally retained
  fixtures. Controls must continue to prove one parser invocation.
4. F7 must retain the nonzero matrix for each exact value/tag call, including
  partial stdout and raw stderr injection. It must separately add successful
  output-shape cases for all four fields: each allowed null/string/integer tag
  combination; quoted numerics; explicit empty strings; multi-line tag output
  for `mode`, `samples`, `passes`, and `teeth`; multi-line and CR-bearing value
  output; map and sequence tags; boolean, float, timestamp, custom, empty, and
  unknown tags; and null/non-null plus integer/value contradictions.
5. Every malformed F7 case must assert exit `2`, exactly empty stdout, exactly
  the stable config parser diagnostic, no raw `yq` bytes, no presence or alias
  metadata, and zero parser-record leakage. Allowed `!!str` empty values must
  reach ordinary selected-value validation rather than becoming absence or a
  parser error. `!!str` and `!!int` numeric controls must preserve quoted and
  unquoted count compatibility.
6. At least one F6 record-consumption case and both nonzero and malformed-
  successful F7 classes must run with a valid higher-precedence directive and
  with valid environment inputs, proving precedence cannot bypass integrity
  inspection. Separate controls must prove valid config still resolves, empty
  directive and valid parse behavior remain compatible, and an actually
  missing `yq` still warns and follows the documented non-config path.
7. F8's existing PATH-selected removal-failure matrix remains a mandatory
  preservation control: valid resolution, validation, parser, config, and
  duplicate-token failures; exact exit classes and diagnostics; no success
  stdout; deterministic retained-record accounting and harness cleanup; normal
  zero-residue paths; and normal/symlink-like disposable `TMPDIR` controls.
8. Anti-overcorrection controls must retain all F1-F5 and existing F8 cases,
  the historical and extended F6 controls, BUG-010 exact keys
  and precedence-before-validation, deprecated-alias metadata/layer order,
  canonical seven-line output order, missing-`yq` compatibility, one parser
  invocation, 128 KiB bounded behavior, deterministic replay, and macOS/Linux
  portable shell forms.
9. After implementation, `bubbles.test` must run the full focused selftest,
  syntax, ShellCheck, regression-quality guard, and scoped change-boundary
  checks. `bubbles.stabilize` must then rerun all eight findings. Canonical
  framework/release, certification, audit, docs disposition, and IMP-020 S2
  reconciliation remain later owner work and are not authorized edits in this
  repair slice.
10. No API, UI, datastore, load, or telemetry test applies to this pure shell
  resolver; none is claimed or fabricated.

### BUG-014 Definition Of Done

- [ ] Prior Sample 01 and Sample 03 evidence is accounted for one-to-one as
  exactly BUG014-F1 through BUG014-F4, with unrelated findings excluded.
  - **Uncertainty Declaration:** The current session read the transcribed
    historical section but did not reopen the two `/tmp` source records.
    The `bubbles.stabilize` rerun must compare those records to the four finding
    IDs before this accounting item can be checked.
- [ ] New focused regressions fail before the fix for the exact four BUG-014
  behavior classes and include no silent-pass bailout.
  - **Uncertainty Declaration:** No real pre-fix failing regression transcript
    was available or executed in this post-fix session. The active top-level
    runner must supply preserved pre-fix red evidence; a synthetic recreation
    after the repair cannot resolve this item.
- [x] The F1-F4 bounded repair is present in the two authorized source/test
  files, and the prior `463/0` evidence includes successful `bash -n` and
  ShellCheck execution. This checked historical claim is not recast as a
  current-session, new-F6/F7, or F8-lifecycle result.
- [x] Complete malformed free-form values are rejected; none is prefix-parsed
  or dropped into a lower precedence/default result.
- [x] Repeated `--directive`, `--mode`, and `--teeth` inputs and
  `adversarial` / `mode` synonym collisions are rejected independently of
  ordering and emit no partial posture.
- [x] Every selected sample input enforces `1..5`; `6` and `1000000000` fail
  through every applicable layer while `1` and `5` pass.
- [x] Explicit `--samples ''` fails as an invalid selected value while true
  absence still resolves the documented default.
- [x] BUG-010 precedence-before-validation and exact-key behavior remains
  green and is not reopened or reimplemented.
- [x] Canonical/deprecated alias compatibility, deprecation metadata,
  precedence, output order, correlated-sample semantics, and exit classes pass
  anti-overcorrection controls.
- [x] The prior F1-F4 focused resolver selftest passed with adversarial signal
  and no disabled or test-created-success path. The later historical `494/0`
  test-owner report is recorded separately and does not expand this checked
  item into the new F6/F7 or F8-lifecycle coverage.
- [ ] BUG014-F5 remains repaired by the current one-parse accepted-input path,
  and the persistent selftest proves one parser invocation plus bounded
  128 KiB behavior without a machine-specific timing threshold.
  > **Uncertainty Declaration**
  > **What was attempted:** This planning recovery inspected the current
  > `parse_directive` / `DIRECTIVE_RECORD` path and persistent one-AWK plus
  > 128 KiB cases; it did not execute them.
  > **What was observed:** Current bytes implement one parse and the prior test
  > owner reported the complete F1-F6 matrix at `494/0`.
  > **Why this is uncertain:** The evidence is historical, and the upcoming
  > F6/F7 edits touch the same resolver/selftest files.
  > **What would resolve this:** `bubbles.test` must execute the full matrix
  > after F6/F7 implementation and preserve the one-invocation and 128 KiB
  > assertions.
- [ ] A persistent long-whitespace regression prevents the F5 growth and
  timeout behavior from returning without relying on a machine-specific timing
  assertion alone.
  > **Uncertainty Declaration**
  > **What was attempted:** Current bytes contain a production-path 128 KiB
  > case with a generous watchdog and byte-identical small-input control.
  > **What was observed:** The later prior test-owner report was `494/0`, and
  > routed hardening reported that F5 held.
  > **Why this is uncertain:** This planning recovery did not execute the case,
  > and no post-F6/F7 result exists.
  > **What would resolve this:** Preserve and execute the current case after the
  > F6/F7 repair, then rerun hardening.
- [ ] BUG014-F6 fails closed for every parser-record production and consumption
  failure: `mktemp`, AWK, missing/unlinked, unreadable, non-regular, malformed,
  and failed read all exit `2` with exactly empty stdout and exactly the stable
  parser-failure diagnostic, without raw shell/tool/path text.
  > **Uncertainty Declaration**
  > **What was attempted:** Current source/selftest and routed hardening results
  > were read; this planning recovery ran no resolver path.
  > **What was observed:** AWK, `mktemp`, and malformed-key controls fail closed,
  > but the routed post-AWK absent/unreadable record path emitted raw shell/path
  > stderr, returned `0`, and published the default posture.
  > **Why this is uncertain:** F6 is actively unresolved; no implementation or
  > green execution exists for complete record consumption.
  > **What would resolve this:** Implement explicit checked consumption and have
  > `bubbles.test` plus `bubbles.stabilize` execute the full F6 matrix.
- [ ] Persistent F6 production-path regressions cover post-AWK unlink,
  unreadable and non-regular records, failed reads, malformed framing/content,
  AWK and `mktemp` controls, empty-directive success, valid parse-once success,
  raw stderr suppression, and deterministic residue cleanup.
  > **Uncertainty Declaration**
  > **What was attempted:** Existing AWK and parse-once cases were inspected;
  > routed hardening supplied the RED counterexample only.
  > **What was observed:** The current selftest lacks the post-production record
  > mutation/read matrix and therefore its `594/0` result does not cover F6.
  > **Why this is uncertain:** Required persistent regressions are not present or
  > executed.
  > **What would resolve this:** Add the listed cases in the authorized selftest
  > and capture independent RED/GREEN plus hardening evidence.
- [ ] BUG014-F7 validates successful output shape in addition to all eight
  available-`yq` statuses: one scalar value line, one field-allowed tag line,
  closed tags, CR/LF rejection, and tag/value consistency all fail closed with
  exact exit/output/diagnostic behavior when violated.
  > **Uncertainty Declaration:** Current status checks reject nonzero and partial
  > output failures, but routed hardening proved that successful multi-line tag
  > output is accepted for all four fields. No shape repair exists.
- [ ] Persistent F7 regressions cover every allowed tag/value combination,
  quoted numerics and explicit empty strings, multi-line tags for all four
  fields, multi-line/CR values, map/sequence and unsupported scalar/custom tags,
  tag/value contradictions, nonzero partial-output controls, directive/env
  precedence non-bypass, valid config, and missing-`yq` compatibility.
  > **Uncertainty Declaration:** Current focused bytes contain the eight-query
  > nonzero matrix and compatibility controls, but no successful malformed-
  > output matrix. Routed hardening is RED evidence, not a repair or green run.
- [ ] BUG014-F8 remains implemented so parser-record cleanup participates in
  the success decision: removal failure cannot publish posture, already-nonzero
  paths remain nonzero, and all resolver-owned residue is accounted for.
  > **Uncertainty Declaration:** Current source/selftest implement these paths,
  > and routed `594/0` plus hardening reported F8 held with no success leak or
  > disposable-`TMPDIR` residue. This planning recovery did not execute that
  > evidence, and independent lifecycle completion must follow F6/F7 changes.
- [ ] Persistent F8 regressions continue to prove valid, validation, parser,
  config, duplicate-token, removal-failure, normal, and symlink-like disposable
  `TMPDIR` paths with exact exits, empty success-failure stdout, stable
  diagnostics, deterministic accounting, and harness-owned residue removal.
  > **Uncertainty Declaration:** Routed hardening reports these controls held;
  > they remain unchecked because the active two-file F6/F7 repair can affect
  > the same lifecycle and has not received independent post-change execution.
- [ ] F6/F7 implementation and F8 preservation tests stay within
  `adversarial-resolve.sh` and `adversarial-resolve-selftest.sh`; no helper,
  generated, release, downstream, documentation, registry, or unrelated IMP-020
  file changes in this repair slice.
  > **Uncertainty Declaration:** Planning defines the boundary; implementation
  > has not yet produced a changed-path set to verify.
- [ ] Exact post-fix production probes reproduce the Expected Behavior with
  current execution evidence.
  - **Uncertainty Declaration:** This planning recovery ran neither the focused
    selftest nor a standalone replay of the historical command matrix. The
    `bubbles.test` and `bubbles.stabilize` reruns must capture current exits,
    stdout, and stderr to resolve this item.
- [ ] `bubbles.test` independently verifies the complete eight-finding focused
  and regression obligations with no collateral failure.
  - **Uncertainty Declaration:** This planning recovery ran no resolver test,
    syntax check, ShellCheck, regression-quality guard, or framework validation.
    Prior `494/0` and routed `594/0` evidence predate the required F6/F7 repair.
- [ ] `bubbles.stabilize` reruns the complete hardening phase after F6/F7 repair
  and returns clean while confirming focused evidence supports, but does not
  exceed, the eight-finding BUG-014 contract.
  - **Uncertainty Declaration:** Routed hardening was non-clean at `507/510` and
    activated F6/F7 while F1-F5/F8 held. A clean rerun cannot be claimed until
    F6/F7 are repaired and the complete persistent matrix executes again.
- [ ] `bubbles.validate` verifies the declared boundary and all unchecked DoD
  evidence before any fixed, verified, or closed status is written.
  - **Uncertainty Declaration:** Validate-owned certification was not run.
    `bubbles.validate` must execute its boundary, evidence, and status checks.
- [ ] `bubbles.audit` independently audits the evidence and finding accounting.
  - **Uncertainty Declaration:** No audit was run. `bubbles.audit` must review
    evidence provenance, DoD precision, and one-to-one finding disposition.
- [ ] `bubbles.docs` reconciles any required operator/release documentation.
  - **Uncertainty Declaration:** No docs phase was run and this edit does not
    infer whether a public-doc delta is required. `bubbles.docs` must decide and
    record that disposition.
- [ ] Canonical framework validation and release checks pass after F6/F7
  repair and a clean eight-finding hardening rerun.
  - **Uncertainty Declaration:** Neither `framework-validate` nor
    `release-check` was run for this reconciliation. The active top-level runner
    must execute both commands and retain their complete outputs.
- [ ] IMP-020 S2 reconciles all eight findings back into its finding ledger and
  remains open for any unrelated S2 blocker, integration, release, or
  certification work.
  - **Uncertainty Declaration:** IMP-020 S2 finding-ledger reconciliation was
    not performed. The active IMP-020 S2 runner must account for BUG014-F1
    through BUG014-F8 without closing unrelated S2 work.

### BUG-014 Current Disposition And Handoff

BUG-014 remains in progress and uncertified. The current resolver and focused
selftest retain F1-F5 repaired behavior, the historical F6 production-failure
repair, checked nonzero `yq` calls, and F8 pre-output cleanup. Prior records
include F1-F4 `463/0`, test-owner-reported `494/0`, and routed hardening-owner
`594/0` focused plus `507/510` production checks; none was executed by this
planning recovery. The routed counterexamples make F6 complete record
consumption and F7 successful output-shape validation the active unresolved
findings. F8 has implementation and focused/hardening evidence but remains
nonterminal pending the independent post-change lifecycle. The finding set
remains exactly F1-F8.

The next required owner is `bubbles.implement`. It must repair F6 and F7 within
the authorized two-file boundary: explicitly check parser-record consumption,
validate successful `yq` output shape and closed tag semantics, add the exact
persistent matrices above, and preserve F1-F5, F8, and BUG-010 controls. It is
not authorized to add a helper/package dependency or edit generated, release,
downstream, documentation, registry, or other IMP-020 surfaces in this slice.
`bubbles.test` must then execute the complete focused matrix independently, and
`bubbles.stabilize` must rerun all eight findings before validate-owned
certification, independent audit, docs disposition, canonical framework/release
checks, or IMP-020 S2 one-to-one reconciliation. This entry makes no fixed,
tested-on-new-F6/F7-cases, stabilized, closed, verified, certified,
release-ready, hardening-clean, or S2-complete claim.

---

## BUG-015 - installed evaluation package omits runtime and contract schemas

- **Filed:** 2026-07-14
- **Status:** Partially resolved (IMP-102 SCOPE-6, 2026-07-25) - BUG015-F1 fixed
  by reclassifying the eval-harness pair to source-only in the generated
  manifest so it is no longer shipped downstream; BUG015-F2 and BUG015-F3 remain
  open (see disposition below)
- **Disposition:** confirmed from current source plus a supported local-source
  install into an isolated temporary Git repository
- **Severity:** high - the installed `eval-harness.sh` cannot evaluate any task,
  and the installed red-team contract names an authoritative sample schema that
  does not exist in the installed package
- **Affected:** `install.sh`, `bubbles/installer/installer.yaml`,
  `bubbles/scripts/trust-metadata.sh`,
  `bubbles/scripts/install-provenance-selftest.sh`,
  `bubbles/scripts/release-manifest-selftest.sh`, and generated
  `bubbles/release-manifest.json`; consumers are
  `bubbles/scripts/eval-harness.sh` and
  `agents/bubbles_shared/agent-common.md`
- **Evidence:** `/tmp/bubbles-imp020-s2-current-sample-03.json` plus the
  current-session isolated install and harness probes below
- **Routing:** `bubbles.devops` -> `bubbles.test` -> `bubbles.validate` ->
  `bubbles.releases` -> IMP-020 S1/S2 finding reconciliation

> **Source-repo artifact convention:** Gate G085 forbids persistent `specs/` in
> the Bubbles source checkout. This compact BUG-015 entry is the complete
> source-repo artifact: status, evidence provenance, reproduction, expected
> installed contract, root cause, scenarios, ownership boundary,
> implementation/test plan, unchecked DoD, and routing. This filing edits only
> `BUGS.md`; it contains no production-source fix.

### BUG-015 Summary And Exact Finding Set

The installer manages top-level governance scripts and shared agent contracts
but classifies every file under `bubbles/eval/` as source-only. That creates one
cohesive installed-package self-containment defect with three manifestations:

1. **BUG015-F1 - direct runtime schemas are absent.** The installed
   `eval-harness.sh` computes `TASK_SCHEMA` and `EVALUATOR_SCHEMA` relative to
   itself as `../eval/schemas/task-v2.schema.json` and
   `../eval/schemas/evaluator-result.schema.json`. Neither path is installed,
   so the harness exits `2` with `schema-contract-unavailable` before it can
   validate or score the caller's task.
2. **BUG015-F2 - the installed S2 record contract is not inspectable.** The
   installed `agent-common.md` requires every red-team invocation to emit a
   record conforming to
   `bubbles/eval/schemas/adversarial-sample.schema.json` version 1, but the
   package omits that path. `adversarial-aggregate.sh` embeds a matching manual
   validator and remains executable; that protects the aggregate consumer but
   does not materialize the authoritative schema for the record-producing agent,
   reviewers, or other installed consumers.
3. **BUG015-F3 - provenance tests encode the incomplete package as correct.**
   `install-provenance-selftest.sh` and `release-manifest-selftest.sh` explicitly
   assert that the adversarial schema is source-only and justify the omission
   solely from the aggregator's embedded validator. They do not account for the
   installed agent contract or the two schemas opened directly by the installed
   evaluation harness.

This entry accounts for the Sample 03 `package.install-contract` finding as
BUG015-F2 and extends the same proven packaging root cause to the directly
runtime-consumed S1 schemas in BUG015-F1. Sample 03's resolver, managed-mode
documentation, and BUG-011 status findings remain outside BUG-015.

### Evidence Provenance

#### Prior IMP-020 S2 Sample

**Claim Source:** interpreted

`/tmp/bubbles-imp020-s2-current-sample-03.json` was read in this invocation. It
records sample `imp020-s2-current-03`, invocation
`imp020-s2-current-invocation-03`, and a blocking
`package.install-contract` finding. Its runtime/model provenance is explicitly
`unverified` and its tool inventory is `self-reported`; BUG-015 does not upgrade
those provenance claims or represent that earlier sample as newly executed.

#### Current Supported Local-Source Install And Installed Harness

**Claim Source:** executed

The current working tree was installed through the supported `--local-source`
path into a new `/tmp` Git repository. The installer reported version `7.20.0`,
`613 managed files`, successful install provenance, and a dirty local source
warning. The disposable repository was removed by the command's `EXIT` trap;
no downstream repository was read or mutated.

**Exact command:**

```bash
cd /Users/pkirsanov/Projects/bubbles
source_root="$PWD"
fixture="$(mktemp -d /tmp/bubbles-bug015-final.XXXXXX)"
trap 'rm -rf "$fixture"' EXIT
git -C "$fixture" init -q
mkdir -p "$fixture/output"
printf '%s\n' 'BUG015_FINAL_INSTALL_BEGIN'
(cd "$fixture" && bash "$source_root/install.sh" --local-source "$source_root" --agents-only)
printf '%s\n' 'BUG015_FINAL_MEMBERSHIP'
for relative_path in agents/bubbles_shared/agent-common.md bubbles/scripts/eval-harness.sh bubbles/scripts/adversarial-aggregate.sh bubbles/eval/schemas/adversarial-sample.schema.json bubbles/eval/schemas/task-v2.schema.json bubbles/eval/schemas/evaluator-result.schema.json; do
  if [[ -e "$fixture/.github/$relative_path" ]]; then
    printf 'INSTALLED %s\n' "$relative_path"
  else
    printf 'ABSENT %s\n' "$relative_path"
  fi
done
grep -nF 'bubbles/eval/schemas/adversarial-sample.schema.json' "$fixture/.github/agents/bubbles_shared/agent-common.md"
printf '%s\n' 'BUG015_FINAL_INSTALLED_HARNESS'
harness_exit=0
(cd "$fixture" && bash .github/bubbles/scripts/eval-harness.sh score --task "$source_root/bubbles/eval/fixtures/negative/tasks/invalid-schema.json" --output "$fixture/output") || harness_exit=$?
printf 'BUG015_FINAL_INSTALLED_HARNESS_EXIT=%s\n' "$harness_exit"
printf '%s\n' 'BUG015_FINAL_REPRO_END'
```

**Observed raw output (relevant contiguous windows from the full installer
transcript):**

```text
BUG015_FINAL_MEMBERSHIP
INSTALLED agents/bubbles_shared/agent-common.md
INSTALLED bubbles/scripts/eval-harness.sh
INSTALLED bubbles/scripts/adversarial-aggregate.sh
ABSENT bubbles/eval/schemas/adversarial-sample.schema.json
ABSENT bubbles/eval/schemas/task-v2.schema.json
ABSENT bubbles/eval/schemas/evaluator-result.schema.json
96:2. Require exactly one JSON result conforming to `bubbles/eval/schemas/adversarial-sample.schema.json` schema version 1 from each actual invocation. A redteam invocation executes one sample and cannot claim to create child invocations or synthetic sample records.
BUG015_FINAL_INSTALLED_HARNESS
{
  "certification": {
    "eligible": false,
    "reason": "evaluation schema contract could not be loaded: FileNotFoundError",
    "status": "input-error"
  },
  "certified": false,
  "checks": [],
  "evaluationErrors": [
    {
      "code": "schema-contract-unavailable",
      "message": "evaluation schema contract could not be loaded: FileNotFoundError"
    }
  ],
  "evaluationStatus": "error",
  "inputValid": false,
  "judge": {
    "error": {
      "code": "judge-not-run",
      "message": "input validation failed"
    },
    "provenance": null,
    "required": false,
    "rubricFindings": [],
    "score": null,
    "status": "unavailable",
    "verdict": "not run",
    "weight": 0
  },
  "passed": false
}
BUG015_FINAL_INSTALLED_HARNESS_EXIT=2
BUG015_FINAL_REPRO_END
```

The caller-supplied negative task is deliberately malformed, but the installed
harness never reaches task validation. The failure is the missing package
schema contract, not the task's expected validation result.

#### Canonical Source-Harness Control

**Claim Source:** executed

The same task and output-directory shape were passed to the canonical source
harness. Its schemas loaded successfully; it reached task validation and
reported the task's actual `passThreshold` defect.

**Exact command:**

```bash
cd /Users/pkirsanov/Projects/bubbles && output_dir="$(mktemp -d /tmp/bubbles-bug015-source-output.XXXXXX)" && trap 'rm -rf "$output_dir"' EXIT && printf '%s\n' 'BUG015_SOURCE_HARNESS_CONTROL_BEGIN' && source_harness_exit=0 && bash bubbles/scripts/eval-harness.sh score --task bubbles/eval/fixtures/negative/tasks/invalid-schema.json --output "$output_dir" || source_harness_exit=$?; printf 'BUG015_SOURCE_HARNESS_CONTROL_EXIT=%s\n' "$source_harness_exit"; printf '%s\n' 'BUG015_SOURCE_HARNESS_CONTROL_END'
```

**Observed raw output (relevant windows):**

```text
BUG015_SOURCE_HARNESS_CONTROL_BEGIN
{
  "certification": {
    "eligible": false,
    "reason": "task schema validation failed",
    "status": "invalid-task"
  },
  "certified": false,
  "checks": [],
  "compatibility": {
    "legacyGatePass": "disabled-unavailable",
    "unknownOptionalCheckStatus": "unavailable-weight-retained",
    "version1": "supported-legacy-non-certifying"
  },
  "deterministicRatio": null,
  "evaluationErrors": [
    {
      "code": "task-schema-invalid",
      "issues": [
        {
          "code": "range",
          "message": "must be a finite number in [0, 1]",
          "path": "$.passThreshold"
        }
      ],
      "message": "task definition failed validation before scoring"
    }
  ],
```

```text
  "taskId": "negative-invalid-schema",
  "taskSchema": "https://bubbles.dev/eval/schemas/task-v2.schema.json",
  "taskSchemaVersion": 2
}
BUG015_SOURCE_HARNESS_CONTROL_EXIT=2
BUG015_SOURCE_HARNESS_CONTROL_END
```

The equal numeric exit is not equivalent behavior: source reports the intended
`task-schema-invalid`; installed reports `schema-contract-unavailable` before
examining the task.

#### Installed Aggregator Control

**Claim Source:** interpreted

The separately installed `adversarial-aggregate.sh` was executed against the
supplied schema-valid Sample 03 with:

```bash
bash .github/bubbles/scripts/adversarial-aggregate.sh --expected-samples 1 /tmp/bubbles-imp020-s2-current-sample-03.json
```

Its complete one-line JSON output reported `actualSamples:1`, `errors:[]`, and
`outcome:"agreement-findings"`; the explicit terminal marker was:

```text
BUG015_INSTALLED_AGGREGATOR_CONTROL_EXIT=0
BUG015_INSTALLED_AGGREGATOR_CONTROL_END
```

**Interpretation:** this control agrees with current source inspection:
`adversarial-aggregate.sh` embeds its validator and does not open the sample
schema at runtime. It narrows the defect; it does not make the installed
producer contract self-contained.

### Expected Installed Contract

1. Every managed executable or agent contract MUST have its non-optional
   framework-owned runtime and contract dependencies materialized by the same
   supported install.
2. Because installed `eval-harness.sh` opens them directly,
   `bubbles/eval/schemas/task-v2.schema.json` and
   `bubbles/eval/schemas/evaluator-result.schema.json` MUST be installed at
   those exact relative paths.
3. Because installed `agent-common.md` and installed public guidance name it as
   the authoritative closed record contract,
   `bubbles/eval/schemas/adversarial-sample.schema.json` MUST also be installed
   at its exact referenced path. The aggregator's embedded validator MUST stay
   behaviorally aligned with it.
4. All three schemas MUST be framework-managed: present in `.manifest`, covered
   by `.checksums`, and listed under `managedFileChecksums`, not
   `sourceOnlyFileChecksums`, in the generated release manifest.
5. A supported install followed by an installed harness invocation with a
   caller-supplied task and output directory MUST reach task validation/scoring;
   it MUST NOT fail because its own package schema is missing.
6. Golden tasks, oracle/adapter samples, and positive/negative fixtures under
   `bubbles/eval/tasks/**` and `bubbles/eval/fixtures/**` are source-side
   regression assets and MAY remain source-only. Installing the three schemas
   does not imply shipping the golden corpus or test fixtures downstream.
7. Installed `adversarial-aggregate.sh` MAY retain its standard-library manual
   validator for dependency-free execution, but that duplicate validator is a
   consumer implementation, not a substitute for packaging the authoritative
   schema referenced by other installed surfaces.

### Confirmed Root Cause In Current Source

**Claim Source:** interpreted

1. `install.sh` copies `bubbles/schemas/` into
   `.github/bubbles/schemas/` and installs every top-level script via
   `bubbles/scripts/*.sh`, but it has no copy step for
   `bubbles/eval/schemas/`. Thus the harness is installed without the two files
   it resolves relative to itself.
2. `bubbles_framework_manifest_entries` in `trust-metadata.sh` enumerates
   `bubbles/schemas/` but never enumerates `bubbles/eval/schemas/`. The typed
   installer registry similarly has `install_schemas` with
   `source_dir: bubbles/schemas` and no eval-schema step.
3. `generate-release-manifest.sh` takes every tracked file below
   `bubbles/eval/` and unconditionally appends it to `source_only_entries`.
   Therefore all three schemas are recorded as source-only rather than package
   dependencies.
4. `install-provenance-selftest.sh` explicitly calls
   `assert_bug_009_source_only_release_entry` for only the adversarial schema,
   with prose claiming downstream execution is complete because the aggregator
   embeds a validator. `release-manifest-selftest.sh` likewise requires that
   schema to remain source-only. Neither assertion exercises installed
   `eval-harness.sh` or checks its two direct schema dependencies.
5. `framework-validate.sh` invokes both the aggregate and eval-harness selftests
   through `run_check_self_only`. Source tests can therefore remain green while
   the normally installed harness is unusable; no current installed-package
   regression invokes that harness after installation.

### Adversarial Regression Scenarios

```gherkin
Feature: Install a self-contained evaluation contract

  Scenario: Installed harness reaches task validation
    Given a supported local-source install in an isolated Git repository
    And a caller supplies an existing malformed v2 task and output directory
    When the installed eval-harness scores the task
    Then it reports task-schema-invalid for the malformed task
    And it does not report schema-contract-unavailable

  Scenario: Installed harness has both direct schema dependencies
    Given a supported install completed
    When the installed harness resolves its schema paths relative to itself
    Then task-v2.schema.json exists at the resolved task-schema path
    And evaluator-result.schema.json exists at the resolved evaluator path
    And both files are manifest-owned and checksum-protected

  Scenario: Installed red-team producers can inspect the named contract
    Given installed agent-common requires adversarial sample schema version 1
    When an agent or reviewer resolves the named repository-relative path
    Then adversarial-sample.schema.json exists there
    And its installed bytes match canonical source and release provenance

  Scenario: Removing one runtime schema is detected adversarially
    Given a clean isolated install
    And one directly consumed eval schema is removed from the fixture
    When installed-package provenance and the harness regression run
    Then the provenance check fails
    And the harness reports schema-contract-unavailable
    And a supported reinstall restores the file and intended task result

  Scenario: Source-only eval assets remain source-only
    Given the package installs all three eval schemas
    When package membership is inspected
    Then golden tasks and positive and negative fixtures remain absent
    But an installed harness can evaluate a caller-supplied task

  Scenario: Embedded aggregation stays aligned
    Given a schema-valid adversarial sample record
    When the installed dependency-free aggregator consumes it
    Then its embedded validator accepts the record
    And a schema-invalid adversarial record is rejected by both the JSON schema
      regression and the embedded validator for the same contract reason
```

### BUG-015 Ownership And Change Boundary

`bubbles.bug` owns only this `BUGS.md` artifact. The package repair belongs to
`bubbles.devops`, because it changes installer enumeration, installed
provenance, and package-integrity tests. `bubbles.test` owns independent
regression execution, `bubbles.validate` owns the completion verdict, and
`bubbles.releases` owns generated release-manifest/checksum freshness and any
release-facing version/changelog work after validation.

**Authorized implementation surfaces:**

- `install.sh` - copy the eval schema directory to the matching installed path.
- `bubbles/installer/installer.yaml` - declare the typed install step.
- `bubbles/scripts/trust-metadata.sh` - enumerate the three schemas as managed.
- `bubbles/scripts/generate-release-manifest.sh` - prevent managed eval schemas
  from also being classified source-only.
- `bubbles/scripts/install-provenance-selftest.sh` - prove installed bytes,
  ownership, checksums, executable consumer behavior, and reinstall repair.
- `bubbles/scripts/release-manifest-selftest.sh` - assert all three schemas are
  managed and excluded from source-only provenance.
- Mechanically generated installer/release artifacts only through their owning
  generators and release phase.

**Excluded:** schema content, `eval-harness.sh` scoring behavior,
`adversarial-aggregate.sh` aggregation behavior, agent wording, golden tasks,
eval fixtures, downstream installed copies, unrelated IMP-020 findings, and
BUG-010/BUG-011/BUG-014. A source change outside the authorized package surfaces
requires a new grounded finding and owner route; it is not bundled here.

### BUG-015 Implementation Plan

1. In the installer provenance selftest, first add a real isolated-install
   regression for all three schema paths and invoke installed
   `eval-harness.sh` with a caller-supplied malformed task. Record the pre-fix
   missing-file assertions and `schema-contract-unavailable` failure.
2. Add one typed `bubbles/eval/schemas` directory-copy step to
   `installer.yaml` and the matching `install.sh` copy operation, preserving the
   exact `bubbles/eval/schemas/...` relative paths consumed by scripts and docs.
3. Extend `bubbles_framework_manifest_entries` to own only
   `bubbles/eval/schemas/**`. Adjust source-only release enumeration so managed
   eval schemas cannot appear in both checksum sections; leave tasks and
   fixtures source-only.
4. Replace the current source-only assertions with managed-install assertions
   for all three schemas. Add byte-parity, `.manifest`, `.checksums`, generated
   release-manifest, removal-detection, and supported-reinstall checks.
5. Add an installed consumer regression that distinguishes the intended
   `task-schema-invalid` result from package-level
   `schema-contract-unavailable`. Add an aggregator/schema parity negative case
   without removing the embedded validator.
6. Keep generated release metadata out of the devops implementation claim until
   `bubbles.test` and `bubbles.validate` have accepted the focused behavior;
   then route to `bubbles.releases` for manifest-last regeneration and release
   readiness.

### BUG-015 Test Plan

1. `bubbles.test` runs the focused installer-provenance and release-manifest
   selftests with full output on the current macOS source checkout.
2. Execute the exact isolated install/harness reproduction above after the fix.
   Assert the three schema files are installed and the harness emits
   `task-schema-invalid`, not `schema-contract-unavailable`, for the same task.
3. Remove each direct runtime schema in separate isolated-fixture cases, prove
   the consumer/provenance checks fail, and prove a supported reinstall repairs
   bytes and checksum ownership. This is the adversarial regression signal.
4. Run `eval-harness-selftest.sh` and `adversarial-aggregate-selftest.sh` to
   protect S1 scoring/fail-closed behavior, S2 schema/manual-validator parity,
   and all source-only fixture behavior.
5. Run the installed aggregator against a valid sample plus invalid closed-
   schema cases. Verify keeping the authoritative schema installed does not add
   a runtime JSON-Schema-library dependency.
6. Run canonical `bash bubbles/scripts/cli.sh framework-validate`. After
   release-owned generated artifacts are refreshed, run canonical
   `bash bubbles/scripts/cli.sh release-check` and verify no managed/source-only
   duplicate path exists.
7. No UI, API, datastore, stress, load, or telemetry test applies to this
   installer/package-membership defect; those categories must not be fabricated
   as evidence.

### IMP-020 S1/S2 Reconciliation

- **S1 behavior remains implemented, but installed delivery is not yet
  self-contained.** S1 owns `eval-harness.sh`, `task-v2.schema.json`, and
  `evaluator-result.schema.json`. Its source selftest and fail-closed behavior
  are not invalidated by BUG-015, but S1's completed status must not be read as
  proof that its installed harness works until BUG015-F1 is fixed and verified.
- **S2 package finding is filed one-to-one.** Sample 03's
  `package.install-contract` finding maps to BUG015-F2. The aggregator's passing
  installed control is retained as evidence that its embedded validator works,
  not as closure of the producer-contract gap.
- **S2 remains pending.** BUG-015 does not reconcile Sample 03's resolver,
  managed-mode documentation, or BUG-011 status findings and does not claim the
  S2 live three-sample contract, framework validation, or release acceptance.
- **S7/release reconciliation cannot erase this blocker.** The fix must land in
  the owning S1/S2 package surfaces with focused red/green evidence before final
  public/generated reconciliation or a release-complete claim.

### BUG-015 Definition Of Done

- [ ] Sample 03 `package.install-contract` is accounted for exactly once as
  BUG015-F2, and its unrelated findings remain separately dispositioned.
- [ ] A persistent installed-package regression fails before the fix with the
  three missing schema paths and installed-harness
  `schema-contract-unavailable` result.
- [ ] `adversarial-sample.schema.json`, `task-v2.schema.json`, and
  `evaluator-result.schema.json` install at their exact consumed/referenced
  paths with bytes matching canonical source.
- [ ] All three schemas are owned by `.manifest`, recorded in `.checksums`, and
  present only in `managedFileChecksums` in release provenance.
- [ ] Golden tasks, oracles/adapters, and positive/negative eval fixtures remain
  source-only and are not pulled into the downstream package by over-broad copy
  or manifest enumeration.
- [ ] Installed `eval-harness.sh` reaches task validation/scoring with a
  caller-supplied task and never fails because a framework-owned schema is
  absent.
- [ ] Installed `adversarial-aggregate.sh` remains dependency-free, accepts
  schema-valid records, rejects adversarial invalid records, and stays aligned
  with the installed authoritative schema.
- [ ] Removing each runtime schema makes the focused regression fail, and a
  supported reinstall restores file bytes, mode, manifest membership, and
  checksum provenance.
- [ ] Typed installer declaration, generated installer check, copy behavior,
  manifest enumeration, source-only classification, and selftest assertions all
  describe the same package boundary.
- [ ] Focused S1 eval-harness and S2 adversarial-aggregate selftests pass after
  the package fix with no weakened assertion, silent bailout, or fabricated
  installed fixture.
- [ ] `bubbles.test` independently records focused and canonical framework
  results with no collateral regression.
- [ ] `bubbles.validate` verifies the authorized change boundary, adversarial
  signal, and one-to-one finding coverage before any fixed/verified status.
- [ ] `bubbles.releases` regenerates release metadata last and records a passing
  `release-check`; no release or propagation claim precedes that evidence.
- [ ] No downstream repo is patched manually; repaired installed copies are
  produced only by the supported installer/upgrade path after canonical release.
- [ ] IMP-020 reconciles BUG015-F1 with S1 installed delivery and BUG015-F2 with
  S2 finding accounting while leaving every unrelated IMP-020 blocker open.

### BUG-015 Current Disposition And Handoff

**Update 2026-07-25 (IMP-102 SCOPE-6 - BUG015-F1 resolved).** BUG015-F1 is
resolved. Evidence in this working tree established that the golden-task eval
harness is framework-source-only: its selftest is wired through
`run_check_self_only` (SKIPPED in downstream `framework-validate`), and the
entire `bubbles/eval/` payload it consumes (including
`bubbles/eval/schemas/task-v2.schema.json` and
`bubbles/eval/schemas/evaluator-result.schema.json`) is already classified
source-only. `bubbles/scripts/generate-release-manifest.sh` now reclassifies
`bubbles/scripts/eval-harness.sh` and `bubbles/scripts/eval-harness-selftest.sh`
out of the managed set and into `sourceOnlyFileChecksums`, so the regenerated
`bubbles/release-manifest.json` no longer owns them as managed. `install.sh`'s
existing managed-script prune (`release_manifest_owns_managed_path`) therefore
removes the harness pair from every downstream install, eliminating the broken
`../eval/schemas/...` relative reference that previously made `eval-harness.sh`
exit 2 with `schema-contract-unavailable`. No downstream-run script invokes the
harness at runtime (`eval-heldout-guard.sh` names it only in comments;
`forecast-eval-check.sh` is standalone), so the demotion creates no dangling
reference. This was chosen over promoting the two schemas into the managed set
because downstream never runs the harness at all, so demotion is the smaller,
self-consistent change (the whole eval subsystem stays source-only).

**Still open (NOT in IMP-102 SCOPE-6 scope).** BUG015-F2 (the installed
`agent-common.md` red-team contract still names
`bubbles/eval/schemas/adversarial-sample.schema.json`, which remains
source-only while `adversarial-aggregate.sh` keeps its embedded validator) and
BUG015-F3 (the `install-provenance-selftest.sh` /
`release-manifest-selftest.sh` provenance assertions that document the
source-only eval classification) are unrelated to the eval-harness runtime
schema reference fixed here and are deliberately left untouched.

The next required owner for the still-open findings is `bubbles.devops` for the
bounded installer, manifest-enumeration, and package-provenance repair. Route
its result to `bubbles.test` for independent adversarial execution, then to
`bubbles.validate` for boundary and finding-coverage validation, then to
`bubbles.releases` for generated manifest/release readiness, and finally back
to the IMP-020 orchestrator for S1/S2 one-to-one reconciliation.

---

## BUG-016 - adversarial aggregate accepts non-RFC3339 sample timestamps

- **Filed:** 2026-07-14
- **Status:** Reported / Not Started - no runtime, schema, selftest, or release
  source has been changed
- **Disposition:** confirmed from historical IMP-020 S2 red-team evidence and
  current source inspection; no current-session production probe was executed
- **Severity:** high - the S2 trust aggregator can accept an out-of-contract
  sample as agreement-clear, so malformed invocation provenance can enter a
  supposedly schema-valid adversarial result set
- **Affected:** `bubbles/scripts/adversarial-aggregate.sh::validate_timestamp`
  and `bubbles/scripts/adversarial-aggregate-selftest.sh`; the declared
  contract is `bubbles/eval/schemas/adversarial-sample.schema.json::invokedAt`
- **Finding:** `IMP020-S2-RT-02B-001` / aggregate fingerprint
  `sha256:b7549f72a4a41f14aa09e01d5b0a440a4403223d78e3b297e76fa6a4d5ac34f0`
- **Evidence:** historical sample
  `/tmp/bubbles-imp020-s2-current-sample-02b.json`, historical VS Code session
  transcript `da09f9b1-1e85-49da-8612-2e14598070c3.jsonl` around lines
  2750-2770, and current source inspection recorded below
- **Routing:** `bubbles.implement` -> `bubbles.test` -> `bubbles.validate` ->
  IMP-020 S2 one-to-one finding reconciliation

> **Source-repo artifact convention:** Gate G085 forbids persistent `specs/`
> in the Bubbles source checkout. This compact BUG-016 entry is the complete
> source-repo artifact: status, severity, evidence provenance, exact
> reproduction, observed and expected behavior, root cause, regression
> scenarios, change boundary, implementation/test plan, unchecked DoD, and
> routing. This filing edits only `BUGS.md`; it contains no production fix.

### BUG-016 Summary

The adversarial sample schema declares `invokedAt` as JSON Schema
`format: "date-time"`, which is the RFC 3339 date-time contract. The production
aggregator instead translates a trailing uppercase `Z` to `+00:00` and delegates
the entire remaining check to Python `datetime.datetime.fromisoformat`.
`fromisoformat` accepts a broader ISO-8601 grammar than RFC 3339, including the
compact numeric offset `+0000`.

The historical IMP-020 S2 red-team probe supplied an otherwise valid sample
whose timestamp was `2026-07-14T12:00:00+0000`. The production aggregator
accepted it with exit `0`, no aggregation errors, and
`outcome: "agreement-clear"`. Ruby standard-library `DateTime.rfc3339`, used as
an independent local oracle, rejected the same string. This is contract/runtime
drift, not a request to broaden the schema: the expected repair is to make the
dependency-free runtime validator conform to the existing RFC 3339 contract.

The persisted sample `imp020-s2-current-02b` is itself a valid schema-v1 finding
record with a `Z` timestamp. It records the disposable invalid-timestamp probe;
it is not the malformed fixture that triggered the counterexample.

### BUG-016 Evidence Provenance

#### Historical IMP-020 S2 Counterexample

**Claim Source:** interpreted

The cited session transcript records a red-team invocation with sample ID
`imp020-s2-current-02b` and invocation ID
`imp020-s2-current-invocation-02b`. Its runtime, model, and tool identities were
explicitly unverified and no independence claim was made. The invocation
reported one blocking finding:

```text
category=schema-validation
target=bubbles/scripts/adversarial-aggregate.sh::validate_timestamp
candidate=2026-07-14T12:00:00+0000
productionOutcome=agreement-clear
productionErrors=[]
oracle=ruby-standard-library-DateTime.rfc3339
oracleResult=rejected
findingId=IMP020-S2-RT-02B-001
```

The transcript records the focused selftest as `124 passed, 0 failed`, while
the disposable 13-case red-team fixture suite had zero harness failures and one
production counterexample: this timestamp. Those are historical results, not
commands re-executed while filing BUG-016.

#### Historical Three-Sample Aggregate

**Claim Source:** interpreted

The exact historical aggregation command was:

```bash
bash bubbles/scripts/adversarial-aggregate.sh --expected-samples 3 \
  /tmp/bubbles-imp020-s2-current-sample-01.json \
  /tmp/bubbles-imp020-s2-current-sample-02b.json \
  /tmp/bubbles-imp020-s2-current-sample-03.json
```

Its output reported `expectedSamples: 3`, `actualSamples: 3`, `errors: []`, and
`outcome: "disagreement"`. The sample matrix retained three distinct IDs and
three distinct invocation IDs. Its complete eight-finding union included the
timestamp finding above under only sample `imp020-s2-current-02b`; BUG-016 is
that finding's one-to-one source-repo accounting record. The other seven union
findings remain outside this bug and must not disappear from IMP-020 S2
reconciliation.

#### Historical RFC 3339 Oracle

**Claim Source:** interpreted

The transcript records this local, standard-library-only oracle command:

```bash
ruby -r date -e 'value = "2026-07-14T12:00:00+0000"; begin; DateTime.rfc3339(value); puts "oracleResult=accepted"; exit 1; rescue Date::Error => error; puts "oracleResult=rejected"; puts "oracleErrorClass=#{error.class}"; puts "oracleErrorMessage=#{error.message}"; exit 0; end'
```

It recorded `oracleResult=rejected` and exit `0`. Ruby availability and this
result belong to the historical session. This filing did not rerun Ruby and
does not infer its availability on another host. No `jsonschema` package was
required or invoked for this finding.

#### Current Source Inspection

**Claim Source:** interpreted

Current source still contains the mismatch:

1. `adversarial-sample.schema.json` declares `invokedAt` as a string with
   `format: "date-time"`.
2. `validate_timestamp` accepts any non-empty string parsed by
   `datetime.datetime.fromisoformat` after translating only a trailing uppercase
   `Z`; it then checks only that `tzinfo` is present.
3. `adversarial-aggregate-selftest.sh` generates its base fixtures with only
   `2026-07-11T12:00:00Z`. It has no positive numeric-offset control and no
   adversarial timestamp grammar matrix, so the broader parser remains green.
4. The selftest has a separate schema-check helper that imports optional
   `jsonschema`. BUG-016 regression coverage must exercise the production
   aggregator directly and must not make that optional package the timestamp
   oracle or a prerequisite for the new cases.

No current-session command executed the production aggregator or an RFC 3339
oracle while filing this entry. Current-session claims are limited to reading
the historical evidence and current source.

### BUG-017 Exact Reproduction And Observed Behavior

The historical disposable probe can be reproduced without changing production:

1. Create an otherwise valid schema-v1 sample in an isolated temporary
   directory with unique `sampleId` and `invocationId`, `status: "completed"`,
   `verdict: "clear"`, complete provenance, no findings, and
   `invokedAt: "2026-07-14T12:00:00+0000"`.
2. Run the production consumer against that one file:

   ```bash
   bash bubbles/scripts/adversarial-aggregate.sh --expected-samples 1 \
     "$fixture/non-rfc3339-offset.json"
   ```

3. Run the Ruby command above only when `ruby` and its standard-library `date`
   module are available. If unavailable, record `oracle=unavailable`; do not
   install a package, require `jsonschema`, or convert absence into a pass.

**Observed historically:** step 2 exited `0` and emitted
`outcome: "agreement-clear"` with `errors: []`; the available Ruby oracle
rejected the timestamp.

**Expected:** step 2 exits with the aggregator's schema/input error status,
emits `outcome: "aggregation-error"`, and includes a `schema-date-time` error
whose path identifies the sample's `.invokedAt`. The malformed sample must not
enter `sampleIds`, `sampleMatrix`, agreement, disagreement, or finding-union
semantics as a valid record.

### BUG-016 Confirmed Root Cause

`datetime.datetime.fromisoformat` is an ISO-8601 convenience parser, not an RFC
3339 contract validator. The current function has no lexical gate for the
closed RFC 3339 shape before calling it. Presence of `tzinfo` distinguishes a
naive timestamp from an aware one, but cannot distinguish valid `+00:00` from
out-of-contract `+0000`, a space separator, an hour-only offset, or an offset
with seconds. In the other direction, Python `datetime` cannot directly
represent RFC 3339's permitted leap second. The selftest's single uppercase `Z`
fixture satisfies both parsers, so it is tautological with respect to both
over-acceptance and under-acceptance drift.

The schema already expresses the intended public contract. Changing or
weakening its `date-time` declaration would make the implementation's broader
acceptance authoritative after the fact and is not the expected fix.

### BUG-016 Adversarial Regression Scenarios

```gherkin
Feature: Keep adversarial sample timestamps conformant with RFC 3339

  Scenario: UTC Z timestamp remains valid
    Given an otherwise valid completed sample
    And invokedAt is "2026-07-14T12:00:00Z"
    When adversarial-aggregate consumes exactly that sample
    Then it accepts the record
    And it reports agreement-clear with no aggregation errors

  Scenario: Colonized numeric UTC offset remains valid
    Given an otherwise valid completed sample
    And invokedAt is "2026-07-14T12:00:00+00:00"
    When adversarial-aggregate consumes exactly that sample
    Then it accepts the record
    And it reports agreement-clear with no aggregation errors

  Scenario: RFC 3339 lowercase separators remain valid
    Given an otherwise valid completed sample
    And invokedAt is "2026-07-14t12:00:00z"
    When adversarial-aggregate consumes exactly that sample
    Then it accepts the record
    And it reports agreement-clear with no aggregation errors

  Scenario: An RFC 3339 leap second remains valid
    Given an otherwise valid completed sample
    And invokedAt is "1990-12-31T23:59:60Z"
    When adversarial-aggregate consumes exactly that sample
    Then it accepts the record
    And it reports agreement-clear with no aggregation errors

  Scenario: Compact numeric offset is rejected
    Given an otherwise valid completed sample
    And invokedAt is "2026-07-14T12:00:00+0000"
    When adversarial-aggregate consumes exactly that sample
    Then it reports aggregation-error
    And schema-date-time identifies invokedAt

  Scenario Outline: ISO-8601 extensions outside RFC 3339 are rejected
    Given an otherwise valid completed sample
    And invokedAt is <timestamp>
    When adversarial-aggregate consumes exactly that sample
    Then it reports aggregation-error
    And schema-date-time identifies invokedAt

    Examples:
      | timestamp                              | boundary                 |
      | "2026-07-14 12:00:00+00:00"          | space instead of T       |
      | "2026-07-14T12:00:00+00"             | hour-only offset         |
      | "2026-07-14T12:00:00+00:00:30"       | offset includes seconds  |
      | "20260714T120000+00:00"               | compact date and time    |
      | "2026-07-14T12:00:00,123Z"            | comma fraction separator |
      | "2026-07-14T12:00:00"                | timezone absent          |

  Scenario: Fractional seconds preserve the declared contract
    Given an otherwise valid completed sample
    And invokedAt is "2026-07-14T12:00:00.123456Z"
    When adversarial-aggregate consumes exactly that sample
    Then it accepts the record
    And it reports agreement-clear with no aggregation errors

  Scenario: Calendar and offset semantics remain fail-closed
    Given otherwise valid completed samples with an impossible calendar date or
      an out-of-range timezone offset
    When adversarial-aggregate consumes each sample separately
    Then each result is aggregation-error
    And each error identifies invokedAt without a traceback

  Scenario: Optional independent oracle cannot mask runtime behavior
    Given the production timestamp matrix has direct expected outcomes
    When Ruby DateTime.rfc3339 is available
    Then the selftest compares the same boundary strings with that oracle
    But when Ruby is unavailable it records the oracle check as unavailable
    And the mandatory production assertions still execute and decide the test
```

The invalid `+0000` case is the required adversarial signal: restoring the
current `fromisoformat`-only implementation must make the focused regression
fail. No test may return early or silently pass when the malformed sample is
accepted.

### BUG-016 Change Boundary

`bubbles.bug` owns only this `BUGS.md` filing. The expected implementation is a
two-file runtime-conformity change owned by `bubbles.implement`:

- `bubbles/scripts/adversarial-aggregate.sh` - make `validate_timestamp`
  enforce the existing RFC 3339 lexical and semantic contract with standard
  library facilities only, preserving structured `schema-date-time` errors.
- `bubbles/scripts/adversarial-aggregate-selftest.sh` - add valid controls,
  adversarial invalid boundaries, direct production assertions, and an
  optional guarded Ruby-oracle comparison.

`bubbles/eval/schemas/adversarial-sample.schema.json` is excluded because its
existing `date-time` declaration is the controlling contract. It may enter the
change set only if implementation design demonstrates a genuine contract
defect and explicitly routes that contract change for review; parser
convenience is not such a defect. Generated release metadata, documentation,
resolvers, agents, downstream installed copies, and the other seven IMP-020 S2
findings are also excluded.

### BUG-016 Implementation Plan

1. Add the direct production regression matrix to the focused selftest first.
   Preserve evidence that `+0000` fails the new assertion before the runtime
   fix while `Z` and `+00:00` remain green controls.
2. Replace the permissive timestamp acceptance condition with a strict RFC
  3339 lexical gate followed by standard-library semantic validation. Accept
  `T`/`t`, `Z`/`z`, optional dot-prefixed fractional seconds, colonized
  `+/-HH:MM` offsets, and the contract's leap-second boundary; reject ISO-8601
  extensions outside that grammar before they can reach aggregation semantics.
3. Preserve existing error vocabulary and paths: malformed timestamps produce
   `schema-date-time` at the relevant `.invokedAt`, aggregate to
   `aggregation-error`, and never emit a Python traceback.
4. Keep the implementation dependency-free. Do not add or require
   `jsonschema`. If Ruby is present, use `DateTime.rfc3339` only as a guarded
   independent test oracle; if absent, print a clear unavailable/SKIP record
   while still running every mandatory production assertion.
5. Run the focused selftest and exact one-sample CLI matrix, then route the
   unchanged two-file diff and full outputs to `bubbles.test`.

### BUG-016 Test Plan

1. `bubbles.test` runs the focused aggregate selftest and verifies the added
   `+0000` regression fails against the pre-fix validator and passes after the
   runtime repair. The evidence must distinguish those two executions.
2. Run separate one-sample end-to-end CLI cases for valid `Z`, valid `+00:00`,
   valid lowercase `t`/`z`, valid fractional seconds, a valid leap second,
   invalid `+0000`, space separator, hour-only offset, offset seconds, compact
   date/time, comma fraction, missing timezone, impossible date, and
   out-of-range offset. Assert status, outcome, error code, and error path for
   each case.
3. When Ruby stdlib is available, compare the same boundary table with
   `DateTime.rfc3339` and record the raw result. When unavailable, record that
   fact; do not install dependencies and do not omit the production cases.
4. Run a three-distinct-invocation aggregate with valid RFC 3339 timestamps to
   protect canonical ordering, complete finding union, and disagreement
   behavior. Run the same aggregate with one invalid timestamp and prove it
   fails closed as an aggregation error rather than silently dropping or
   counting the sample.
5. Run canonical `bash bubbles/scripts/cli.sh framework-validate` after the
   focused checks. `bubbles.validate` then inspects the two-file boundary,
   regression quality, absence of silent bailouts, and one-to-one IMP-020
   finding accounting.
6. No UI, network, datastore, container, telemetry, stress, or load category
   applies. The production CLI invocation is the end-to-end consumer contract;
   unrelated categories must not be fabricated as evidence.

### BUG-016 Definition Of Done

- [ ] `IMP020-S2-RT-02B-001` and fingerprint
  `sha256:b7549f72a4a41f14aa09e01d5b0a440a4403223d78e3b297e76fa6a4d5ac34f0`
  are accounted for exactly once as BUG-016; the other seven historical
  aggregate findings remain separately dispositioned.
- [ ] A persistent direct-production regression fails before the fix because
  `2026-07-14T12:00:00+0000` is wrongly accepted as agreement-clear.
- [ ] Valid `Z`, `+00:00`, lowercase `t`/`z`, fractional-second, and leap-second
  RFC 3339 controls remain accepted with no aggregation errors.
- [ ] Invalid compact offset, wrong separator, hour-only offset, offset with
  seconds, compact date/time, comma fraction, missing timezone, impossible
  date, and out-of-range offset cases all fail closed with `schema-date-time`
  at `.invokedAt`.
- [ ] Invalid samples cannot contribute to agreement, disagreement, sample
  counts, sample matrices, or finding unions as valid records.
- [ ] The timestamp regression uses the production aggregator directly and
  does not require optional `jsonschema` or any network-installed dependency.
- [ ] Ruby `DateTime.rfc3339` results are captured only when Ruby stdlib is
  available; unavailability is reported honestly and never treated as proof.
- [ ] Reintroducing the `fromisoformat`-only validator makes the adversarial
  regression fail, and the test contains no bailout or silent-return pattern.
- [ ] The implementation remains within
  `adversarial-aggregate.sh` and its selftest; the schema remains unchanged
  unless a separately reviewed design proves a contract change is necessary.
- [ ] Existing aggregation behavior for duplicate invocation IDs, exact sample
  counts, canonical ordering, disagreement, complete finding union, hostile
  text, and provenance validation remains passing.
- [ ] `bubbles.test` records focused pre-fix failure, post-fix success, boundary
  matrix, optional-oracle status, and canonical framework output with no
  collateral regression.
- [ ] `bubbles.validate` verifies the two-file boundary, exact consumer
  scenario, adversarial signal, evidence provenance, and zero hidden findings.
- [ ] Canonical framework validation passes after the fix without weakening
  the schema, suppressing errors, or adding a fallback acceptance path.
- [ ] IMP-020 S2 reconciles BUG-016 back to the eight-finding historical union
  before any S2 completion or trust-hardening claim.

### BUG-016 Current Disposition And Handoff

BUG-016 is confirmed, reported, and not started. Every DoD item remains
unchecked. This filing changes only `BUGS.md` and makes no implementation,
pre-fix regression execution, post-fix pass, framework-validation, release, or
IMP-020 S2 completion claim.

The next required owner is `bubbles.implement` for the bounded two-file runtime
conformity repair and regression addition. Route its result to `bubbles.test`
for independent red/green and boundary-matrix execution, then to
`bubbles.validate` for change-boundary and evidence validation, and finally
back to the IMP-020 orchestrator for S2 one-to-one finding reconciliation.

---

## BUG-017 - active workflow mode advertises deprecated passes posture while the terminology regression omits the mode registry

- **Filed:** 2026-07-14
- **Status:** Reported / Not Started - no workflow mode, selftest, runtime,
  generated, release, or downstream source has been changed
- **Disposition:** confirmed from the supplied IMP-020 S2 sample and current
  source inspection; the focused selftest was not rerun while filing this bug
- **Severity:** high - an install-managed active workflow mode contradicts the
  canonical S2 posture vocabulary while the regression intended to prevent
  that drift reports the inspected active surface set as clean
- **Affected:** `bubbles/workflows/modes.yaml` redteam-to-doc active comment and
  `bubbles/scripts/adversarial-aggregate-selftest.sh` active-terminology source
  inventory/classifier assertions
- **Finding:** `BUG-017-F01`, accounting for
  `/tmp/bubbles-imp020-s2-current-sample-03.json::findings[2]`
  (`documentation.managed-mode-staleness`) only; the sample supplies no finding
  fingerprint, so none is invented here
- **Evidence:** supplied sample
  `/tmp/bubbles-imp020-s2-current-sample-03.json` plus current source inspection
  recorded below
- **Routing:** `bubbles.docs` -> `bubbles.test` -> `bubbles.validate` -> IMP-020
  S2 one-to-one finding reconciliation

> **Source-repo artifact convention:** Gate G085 forbids persistent `specs/`
> in the Bubbles source checkout. This compact BUG-017 entry is the complete
> source-repo artifact: status, severity, evidence provenance, exact current
> source observation, observed and expected behavior, root cause, regression
> scenarios, two-file change boundary, implementation/test plan, unchecked
> DoD, and routing. This filing edits only `BUGS.md`; it contains no production
> or test fix.

### BUG-017 Summary

IMP-020 S2 made `samples` the canonical adversarial count and retained `passes`
only as deprecated compatibility input. The active `redteam-to-doc` mode still
contains an install-managed comment saying that the redteam phase resolves its
effective posture as `mode/passes/teeth`. That is active operator/agent guidance,
not a historical transcript or migration example, so it should say
`mode/samples/teeth`.

The focused adversarial aggregate selftest has an active-source terminology
classifier, but its explicit inventory contains 15 surfaces and omits
`bubbles/workflows/modes.yaml`. Its syntax checks cover forms such as
`--passes`, `passes:`, `passes=`, and `adversarial.passes`, while no assertion
targets the slash-delimited active posture tuple. Its positive
`mode/samples/teeth` checks apply to generated public surfaces, not the mode
registry. The supplied current sample therefore records a focused result of
`124 passed, 0 failed` even though the active mode comment remains stale.

This bug does not request a global ban on the word `passes`. Explicitly
qualified compatibility and migration language remains valid, as do historical
records outside the active-current-source inventory. The defect is unqualified
active posture wording plus a regression inventory/assertion gap that cannot
see it.

### BUG-017 Evidence Provenance

#### Supplied IMP-020 S2 Sample

**Claim Source:** interpreted

The supplied schema-version-1 record has:

```text
sampleId=imp020-s2-current-03
invocationId=imp020-s2-current-invocation-03
sampleSemantics=same-runtime-correlated
status=completed
verdict=findings
findingIndex=2
findingCategory=documentation.managed-mode-staleness
findingTarget=bubbles/workflows/modes.yaml redteam-to-doc adversarialControlPlane comment
findingBlocking=true
```

Its runtime identity is derived from the supplied VS Code session-log path and
marked `unverified`. Its provider is `GitHub-Copilot`, model ID is
`unavailable`, and model identity is `unverified`; no model independence is
claimed. Its tool inventory is marked `self-reported` with hash
`sha256:873b57e37e51bdfc20884237441113b50245af407df8b9b5e5bd735c3d704b3c`.
The sample contains three other blocking findings. BUG-017 accounts only for
`findings[2]`; the empty-samples resolver, installed-schema, and stale BUG-011
ledger findings remain outside this artifact and must not disappear from
IMP-020 S2 reconciliation.

#### Exact Current Source Observation

**Claim Source:** interpreted

Current source inspection found the active `redteam-to-doc` block in
`bubbles/workflows/modes.yaml`. Its comment currently reads:

```text
# Adversarial-verification control plane (IMP-002): the redteam phase
# resolves its effective posture (mode/passes/teeth) via
# adversarial-resolve.sh. mode=off short-circuits the phase to a
# completed_diagnostic no-op (zero behavior change on upgrade).
```

The controlling selftest section declares exactly these 15 active surfaces:

```text
agents/bubbles.redteam.agent.md
prompts/bubbles.redteam.prompt.md
agents/bubbles.super.agent.md
agents/bubbles_shared/agent-common.md
bubbles/workflows.yaml
skills/bubbles-workflow-mode-resolution/SKILL.md
docs/recipes/adversarial-verification.md
docs/recipes/cross-model-review.md
docs/guides/AGENT_MANUAL.md
docs/guides/WORKFLOW_MODES.md
docs/recipes/README.md
docs/CATALOG.md
bubbles/cheatsheet/vocabulary.json
docs/CHEATSHEET.md
docs/its-not-rocket-appliances.html
```

`bubbles/workflows/modes.yaml` is absent. The classifier's deprecated-syntax
patterns do not include `mode/passes/teeth`, and the positive
`mode/samples/teeth` assertion is scoped to the three generated surfaces.
Consequently, the source that contains the stale active tuple is neither
scanned nor positively asserted.

#### Focused Selftest Result In The Supplied Sample

**Claim Source:** interpreted

The supplied finding's `evidenceRef` records that the focused
`adversarial-aggregate-selftest.sh` execution reported `124 passed, 0 failed`
while scanning 15 active surfaces. That result belongs to the supplied IMP-020
S2 invocation. This filing did not rerun the selftest and does not recast the
historical result as current-session execution evidence.

#### Filing Execution Boundary

**Claim Source:** not-run

No resolver, aggregator, selftest, framework validation, release check,
installer, or downstream command was executed for this documentation-only
filing. Current-session claims are limited to reading the supplied JSON record,
the current mode comment, the current selftest inventory/classifier, and the
existing BUG headings.

### Exact Reproduction And Observed Behavior

1. Inspect the `redteam-to-doc` `adversarialControlPlane` comment in
   `bubbles/workflows/modes.yaml`.
2. Inspect `active_source_surfaces` and the terminology classifier in
   `bubbles/scripts/adversarial-aggregate-selftest.sh`.
3. Compare the active posture tuple with the canonical S2 contract in the
   current active surfaces, which use `samples`, `BUBBLES_ADVERSARIAL_SAMPLES`,
   and `mode/samples/teeth`.
4. Run the focused selftest only under `bubbles.test` ownership and capture its
   complete result; the supplied sample records the pre-fix result as
   `124 passed, 0 failed`.

**Observed:** the active mode comment says `mode/passes/teeth`; the 15-surface
inventory excludes the file containing that comment; no classifier or positive
marker assertion targets the stale slash-delimited posture tuple; the supplied
focused run remains green.

**Expected:** active mode guidance says `mode/samples/teeth`. The mode registry
is a required active terminology surface, an unqualified
`mode/passes/teeth` tuple is rejected, and a positive assertion binds the
redteam-to-doc control-plane comment to `mode/samples/teeth`. Explicitly marked
deprecated compatibility or historical migration references to `passes` remain
allowed and historical snapshots remain outside the active-source scan.

### BUG-017 Confirmed Root Cause

The S2 terminology migration updated the resolver, agents, public docs, and
generated surfaces but missed the install-managed mode-registry comment. The
regression simultaneously encoded its active source universe as a manually
maintained list and omitted the second workflow registry,
`bubbles/workflows/modes.yaml`.

Adding that path alone is necessary but not sufficient. The current classifier
recognizes deprecated command/config/output forms and misleading independence,
voting, consensus, ensemble, and cross-model claims. It does not recognize the
slash-delimited `mode/passes/teeth` posture tuple. Its positive canonical marker
checks draw from agent-common, two public recipes, and generated outputs, so
they do not require the active mode registry to name the canonical tuple.

The defect is therefore a paired coverage gap:

1. the active source containing the stale statement is absent from the source
   inventory; and
2. the classifier/positive assertions lack the exact posture-tuple boundary
   that would fail if the source were included but regressed later.

The existing same-line qualifier mechanism already supplies the correct policy
shape for compatibility: deprecated or historical `passes` text can be valid
when the same clause identifies it as compatibility/migration material. A
whole-repository or whole-history ban would discard that distinction and is not
the fix.

### BUG-017 Adversarial Regression Scenarios

```gherkin
Feature: Keep active adversarial posture terminology canonical

  Scenario: The active redteam workflow mode names the canonical posture
    Given redteam-to-doc enables the adversarial control plane
    When an agent reads its active mode-registry guidance
    Then the resolved posture is described as mode/samples/teeth
    And passes is not presented as the active count

  Scenario: The mode registry cannot fall outside the terminology inventory
    Given every currently listed active source is clean
    And bubbles/workflows/modes.yaml contains mode/passes/teeth in active prose
    When the active-source terminology scan runs
    Then the scan fails
    And the diagnostic identifies bubbles/workflows/modes.yaml and the stale tuple

  Scenario: Restoring the stale active tuple breaks the focused selftest
    Given the canonical mode comment says mode/samples/teeth
    And the focused selftest is otherwise green
    When an isolated regression fixture changes only that active tuple to mode/passes/teeth
    Then the focused terminology assertion fails
    And no unrelated source mutation is needed to expose the regression

  Scenario Outline: Compatibility context is distinguished from active posture
    Given the classifier inspects <text>
    When it evaluates the passes reference in its own clause
    Then finding is <finding>

    Examples:
      | text                                                        | finding |
      | "resolves effective posture as mode/passes/teeth"          | true    |
      | "mode/passes/teeth is deprecated compatibility syntax"     | false   |
      | "Historical compatibility used mode/passes/teeth"          | false   |
      | "passes: 3"                                                | true    |
      | "passes: 3 is deprecated compatibility syntax"             | false   |

  Scenario: Historical records are not rewritten by active-source enforcement
    Given a historical transcript or migration record truthfully mentions passes
    And it is outside the declared active-current-source inventory
    When BUG-017 terminology validation runs
    Then the record is not globally banned or rewritten
    And only active unqualified posture wording is blocking
```

The required adversarial signal is the stale active tuple with every other
surface clean. Removing `bubbles/workflows/modes.yaml` from the inventory,
removing the posture-tuple classifier, or restoring the stale comment must make
the focused regression fail. Compatibility controls prevent the repair from
becoming an indiscriminate ban.

### BUG-017 Change Boundary

This filing is owned by `bubbles.bug` and changes only `BUGS.md`. The complete
future repair is limited to two files and two owners:

- `bubbles/workflows/modes.yaml` - `bubbles.docs` changes only the
  redteam-to-doc non-executable active comment from `mode/passes/teeth` to
  `mode/samples/teeth`.
- `bubbles/scripts/adversarial-aggregate-selftest.sh` - `bubbles.test` adds
  `bubbles/workflows/modes.yaml` to the active source inventory and adds the
  narrow posture-tuple classifier, positive mode-registry marker, adversarial
  stale-source case, and explicit compatibility/historical controls.

Excluded are `adversarial-resolve.sh`, `adversarial-aggregate.sh`, schemas,
agents, prompts, other workflow definitions, public/generated docs, historical
records, release metadata, installer behavior, downstream managed copies, and
the other findings in the supplied sample. No runtime behavior, compatibility
alias, or historical evidence is removed by this bug.

### BUG-017 Implementation Plan

1. `bubbles.docs` changes the one active redteam-to-doc comment to
   `mode/samples/teeth` without editing executable YAML fields or neighboring
   mode behavior.
2. `bubbles.test` adds `bubbles/workflows/modes.yaml` to
   `active_source_surfaces`. At this filing boundary the emitted clean-surface
   count moves from 15 to 16; future list growth must continue to derive from
   the array rather than hard-code a stale total.
3. Add a dedicated `mode/passes/teeth` active-posture pattern to the existing
   classifier and exercise it through classifier fixtures. Reuse the existing
   same-clause qualifier mechanism so explicit deprecated compatibility and
   historical migration text remains allowed.
4. Add a positive assertion over the mode-registry text requiring
   `mode/samples/teeth` in the redteam-to-doc control-plane guidance. Do not
   satisfy this with a marker from a different file.
5. Preserve a red/green trace: the new stale active-posture fixture and an
   isolated stale-mode-registry projection must fail before the test repair or
   when the old tuple is restored, then pass with the canonical comment and
   complete assertions. Do not edit canonical production source merely to
   manufacture the red run.
6. Keep the selftest dependency-free and portable. Do not add a global grep,
   network dependency, broad historical scan, skip flag, fallback acceptance,
   or silent-return path.
7. Route the exact two-file result to `bubbles.validate`, then return the
   validated finding disposition to IMP-020 S2. Release/package reconciliation
   remains outside BUG-017's two-file boundary and cannot be inferred here.

### BUG-017 Test Plan

1. Run the classifier fixture matrix with unqualified active
   `mode/passes/teeth`, qualified deprecated compatibility syntax, qualified
   historical migration wording, unqualified `passes: 3`, and qualified
   deprecated `passes: 3`. Assert the exact finding boolean for every row.
2. Run the active-source scan with the mode registry included. Assert the path
   is present in the required inventory, all required files exist, and the
   clean-surface count reflects all 16 surfaces at this boundary.
3. Run an isolated stale-mode fixture or equivalent noncanonical projection in
   which only the redteam-to-doc tuple is restored to `mode/passes/teeth`.
   Assert the terminology scan fails and identifies that path/tuple. The test
   must not mutate or rewrite canonical source.
4. Run `bash bubbles/scripts/adversarial-aggregate-selftest.sh` after the
   two-file repair and record full output. The supplied `124/0` result is
   pre-fix gap evidence, not a post-fix pass.
5. Scan the changed selftest for disabled cases, early-success returns, broad
   exclusions, and qualifier rules that would allow unqualified active posture
   wording.
6. Run canonical `bash bubbles/scripts/cli.sh framework-validate` after the
   focused checks. `bubbles.validate` verifies the exact two-file boundary,
   active-versus-compatibility distinction, evidence provenance, and one-to-one
   finding accounting.
7. No UI, API, datastore, network, container, telemetry, stress, or load test
   applies. This is an install-managed comment and source selftest contract;
   unrelated test categories must not be fabricated.

### BUG-017 Definition Of Done

- [ ] `BUG-017-F01` accounts exactly once for supplied sample
  `imp020-s2-current-03::findings[2]`; the sample's other three findings remain
  separately dispositioned.
- [ ] The active redteam-to-doc comment says `mode/samples/teeth` and no
  executable mode field or neighboring behavior changes.
- [ ] `bubbles/workflows/modes.yaml` is a required active terminology surface;
  it cannot be removed from the inventory without a focused test failure.
- [ ] An unqualified active `mode/passes/teeth` tuple is a terminology finding
  with a diagnostic naming the mode-registry path and source line.
- [ ] A positive assertion requires the redteam-to-doc mode-registry guidance
  itself to contain `mode/samples/teeth`; another surface cannot satisfy it.
- [ ] Explicitly qualified deprecated `passes` compatibility syntax remains
  accepted, including the existing resolver alias contract.
- [ ] Explicit historical/migration references remain accepted in their
  qualified context, and historical records outside the active inventory are
  neither scanned globally nor rewritten.
- [ ] The adversarial stale-mode fixture fails before the repair or whenever
  the old active tuple is restored, while canonical and compatibility controls
  pass.
- [ ] The regression contains no disabled case, silent-pass bailout, broad
  file/history exclusion, or qualifier that masks unqualified active wording.
- [ ] The focused adversarial aggregate selftest passes after the repair with
  the complete mode-registry inventory and new classifier/marker assertions.
- [ ] Canonical framework validation passes after the focused selftest without
  changing resolver, aggregator, schema, generated, release, or downstream
  behavior.
- [ ] The final source diff is limited to the one modes.yaml comment and the
  adversarial-aggregate-selftest terminology inventory/assertions.
- [ ] `bubbles.test` records the classifier matrix, stale-source adversary,
  focused post-fix output, regression-integrity scan, and broad framework
  result with no collateral failure.
- [ ] `bubbles.validate` verifies the two-file boundary, exact active-source
  scenario, compatibility controls, evidence provenance, and zero hidden
  finding before any completion claim.
- [ ] IMP-020 S2 reconciles BUG-017 to the supplied sample's complete finding
  set before any S2 completion, trust-hardening, release, or propagation claim.

### BUG-017 Current Disposition And Handoff

BUG-017 is confirmed, reported, and not started. Every DoD item remains
unchecked. This filing changes only `BUGS.md` and makes no documentation fix,
selftest edit, pre-fix regression execution, post-fix pass, framework
validation, release, propagation, downstream, or IMP-020 S2 completion claim.

The next required owner is `bubbles.docs` for the single non-executable active
mode comment. Route that exact result to `bubbles.test` for the terminology
inventory, classifier, positive marker, compatibility controls, and independent
red/green execution. Route the resulting two-file packet to `bubbles.validate`
for boundary and evidence validation, then return it to the IMP-020
orchestrator for S2 one-to-one finding reconciliation.

## BUG-019 - State transition truncates compound MJS test paths

- **Status:** Confirmed; discovery packet blocked on `bubbles.design` ownership
- **Severity:** Medium
- **Reporter:** Research Lab `AUD-005-S01-004`
- **Defect:** Check 8 extracts an existing `*.spec.mjs` path as `*.spec` and
  reports the invented prefix missing; `.test.mjs`, extension-prefix names, and
  extension-shaped prose expose the same token-boundary defect.
- **Discriminator:** Reporter Check 8 derives 21 nonexistent `.spec` rows while
  installed traceability resolves the complete `.spec.mjs` and exits `0`.
- **Canonical packet:**
  `improvements/BUG-019-state-transition-spec-mjs-path/`
- **Boundary:** No source, regression, release, BUG-018, installed-framework, or
  reporter file is changed by intake.
- **Next required owner:** `bubbles.design`
