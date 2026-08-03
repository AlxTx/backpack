# Claude Code adapter

Claude Code CLI and the Claude Desktop Code tab share the same local
configuration. The portable workflow is linked to `~/.claude/rules/backpack.md`.
Shared skills are linked into both `~/.claude/skills` and `~/.agents/skills`;
this adapter adds the Claude-specific subagents under `agents/`.

Install only this adapter with:

```sh
bootstrap/install.sh --only claude --apply
```
