# Claude Code adapter

Claude Code CLI and the Claude Desktop Code tab share the same local
configuration. The portable workflow is linked to `~/.claude/rules/backpack.md`.
The minimal Cockpit core is linked into both `~/.claude/skills` and
`~/.agents/skills`; project skills are managed with `backpack add` and discovered
from project skill folders. This adapter adds the Claude-specific subagents
under `agents/`.

Installation replaces the Backpack rule, the complete Backpack agent directory,
and core-skill paths from their canonical sources. Claude authentication,
settings, histories, and unrelated host state remain untouched.

The delivery flow uses `plan` → `build` → `cockpit-validate` → optional
`cockpit-learn`. Shared capabilities are exposed once as portable skills;
Claude-specific agents exist only for host-native postures or independent Code
Review and Product QA lenses.

Install only this adapter with:

```sh
backpack install cockpit --claude
```
