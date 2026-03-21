# Validation Core

All agent completion checks follow a shared two-tier model.

## Tier 1

Run the universal completion checks defined by shared governance before reporting results.

## Tier 2

Each agent must also satisfy its role-specific validation profile from `validation-profiles.md` before claiming completion.

## Rules

1. Validation claims require actual executed evidence.
2. Agent-specific checks are additive, not optional.
3. If any required Tier 2 check fails, the agent must report failure and must not claim completion.
4. Prompts should reference the matching profile instead of embedding duplicate tables.