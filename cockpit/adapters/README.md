# Host adapters

Each directory contains only the configuration that cannot live in the portable
core. Shared engineering rules, model roles, and skills remain in
`../portable/`.

| Adapter | Covered surfaces | Host-specific payload |
|---|---|---|
| `opencode/` | CLI, TUI, desktop app, GitHub Action | Local config template, agents, commands, prompts, plugins, and themes |
| `claude/` | Claude Code CLI and Desktop Code tab | Rules, subagents, and skills |
| `codex/` | CLI and desktop app | Installation mapping for instructions and shared skills |
| `copilot/` | CLI and desktop app | CLI instructions, shared skills, and an in-app global-instructions setup step |

The installer owns the target paths and symlinks. Copilot App global instructions
are configured only through the app UI, so the installer provides a clipboard
helper instead of writing undocumented application state. Adapter documentation
must not duplicate the portable workflow.
