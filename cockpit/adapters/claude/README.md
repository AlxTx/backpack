# Claude Code adapter

Claude Code CLI and the Claude Desktop Code tab share the same local
configuration. The portable workflow is linked to `~/.claude/rules/backpack.md`.
Shared skills are linked into both `~/.claude/skills` and `~/.agents/skills`;
this adapter adds the Claude-specific subagents under `agents/`.

The delivery flow uses `plan` → `build` → `validate` → optional `learn`.
`validate` keeps Code Review and Product QA as separate lenses and reports RTS
without performing Git actions. `review` and `qa` remain independently usable.

Install only this adapter with:

```sh
backpack install cockpit --claude
```
