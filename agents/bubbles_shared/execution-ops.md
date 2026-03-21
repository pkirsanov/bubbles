# Execution Operations

Use this file for bounded retry behavior and auxiliary workflow operations that should not bloat the main governance index.

## Lessons-Learned Memory

When the repository maintains a lessons-learned memory, agents may append concise entries describing:

- problem
- root cause
- fix
- when the lesson applies

Keep lessons short and actionable.

## Self-Healing Loop Protocol

When a failure is local and fixable, agents may attempt a bounded self-healing loop.

Rules:

- narrow retries only
- maximum three retries for the same failure context
- maximum one nesting depth
- if a new failure appears, it still counts against the same retry budget
- escalate or stop when bounded retries are exhausted

## Atomic Commit Protocol

If a workflow mode explicitly enables automatic commit behavior, commits must remain scoped to the validated unit of work. Do not use auto-commit settings to hide incomplete or unverified work.

## Timeout Policy

All long-running commands or polling loops must have explicit time bounds. Do not wait indefinitely.

On timeout:

1. record the timeout
2. stop or kill hanging work when possible
3. report the bounded failure
4. do not silently continue as if validation succeeded