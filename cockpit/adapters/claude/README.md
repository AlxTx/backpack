# Claude Code adapter

Claude Code CLI and the Claude Desktop Code tab share the same local
configuration. The portable workflow is linked to `~/.claude/rules/backpack.md`.
The minimal Cockpit core is linked into both `~/.claude/skills` and
`~/.agents/skills`; project skills are managed with `backpack add` and discovered
from project skill folders. This adapter adds the Claude-specific subagents
under `agents/`.

The delivery flow uses `plan` → `build` → `validate` → optional `learn`.
`validate` keeps Code Review and Product QA as separate lenses and reports RTS
without performing Git actions. `review` and `qa` remain independently usable.

Install only this adapter with:

```sh
backpack install cockpit --claude
```
