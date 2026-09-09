# Host adapters

Each directory contains only the configuration that cannot live in the portable
core. Shared engineering rules, model roles, the minimal workflow skill set,
and the curated skill catalogue remain in `../portable/`.

| Adapter | Covered surfaces | Host-specific payload |
|---|---|---|
| `opencode/` | CLI, TUI, desktop app, GitHub Action | Local config template, agents, commands, prompts, plugins, and themes |
| `claude/` | Claude Code CLI and Desktop Code tab | Rules, subagents, and skills |
| `codex/` | CLI and desktop app | Read-only validation agents plus installation mapping for instructions and the Cockpit core |
| `copilot/` | CLI and desktop app | FSH workflow bridge plus explicit `/cockpit-*` utilities; hooks remain externally owned |

The installer replaces every selected target path from these canonical sources
and backs up conflicts first. Runtime data and host paths outside this map are
untouched. Adapter documentation must not duplicate the portable workflow.
