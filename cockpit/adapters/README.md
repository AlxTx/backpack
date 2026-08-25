# Host adapters

Each directory contains only the configuration that cannot live in the portable
core. Shared engineering rules, model roles, and skills remain in
`../portable/`.

| Adapter | Covered surfaces | Host-specific payload |
|---|---|---|
| `opencode/` | CLI, TUI, desktop app, GitHub Action | Local config template, agents, commands, prompts, plugins, and themes |
| `claude/` | Claude Code CLI and Desktop Code tab | Rules, subagents, and skills |
| `codex/` | CLI and desktop app | Installation mapping for instructions and shared skills |
| `copilot/` | CLI and desktop app | Personal instructions, shared skills, and the RTK command hook |

The installer owns the target paths and symlinks. Adapter documentation must not
duplicate the portable workflow.
