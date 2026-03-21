# Docs Bootstrap

Always load:
- `critical-requirements.md`
- Feature `spec.md`
- Feature `design.md` and `scopes.md` when they exist
- Only the standard docs targeted by the requested review scope

Load on demand:
- Route files, models, migrations, or UI routes needed to verify documented claims
- `state-gates.md` and `evidence-rules.md` only when documentation updates are tied to completion or validation claims
- Project governance docs only when they define a rule the documentation must reflect exactly

Constraints:
- Track work with `manage_todo_list`
- No redundant rereads without a new reason
- Prefer targeted doc loads over bulk `docs/` reads