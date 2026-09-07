# Bubbles and Codex

Bubbles is a framework source repository. It does not run a product stack. Use
`bash bubbles/scripts/cli.sh framework-validate` to validate framework changes.
Run `bash bubbles/scripts/cli.sh release-check` before a framework release.

## Repository layout

- `agents/` and `prompts/` are the GitHub Copilot integration surface.
- `.codex/agents/` contains the Codex-native specialist configurations.
- `.agents/skills/` exposes the portable Bubbles skills to Codex. Do not copy or
  fork a skill there; it is a symlink to the canonical `skills/` tree.
- `bubbles/mcp/server.py` is the local stdio MCP server.

## Working rules

- Read the relevant skill before applying a governed workflow. Use a skill when
  its description matches the task, or when the user names it.
- Treat the files and commands you inspect as evidence. Do not claim a gate,
  test, or release check passed unless you ran it and report its outcome.
- Keep changes scoped. Do not edit unrelated work already present in the tree.
- For independent, read-heavy investigation, delegate focused subagents and
  collect their results before deciding. Avoid concurrent edits to the same
  files.
- Bubbles' Copilot-specific frontmatter is documentation for that client. In
  Codex, use the project agents under `.codex/agents/` and direct delegation.

## Downstream repositories

The installer places Bubbles' managed files under `.github/`. To enable Codex
there, follow `docs/guides/CODEX.md`; preserve the project-owned `AGENTS.md`,
`.agents/`, and `.codex/` files across framework upgrades.
