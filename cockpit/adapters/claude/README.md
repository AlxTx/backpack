# Claude Code adapter

Claude Code consumes the portable workflow through
`~/.claude/rules/backpack.md`. Shared skills are linked into both
`~/.claude/skills` and `~/.agents/skills`; this adapter adds the Claude-specific
subagents under `agents/`.

Install only this adapter with:

```sh
bootstrap/install.sh --only claude --apply
```
