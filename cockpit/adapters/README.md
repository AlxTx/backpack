# Host adapters

Each directory contains only the configuration that cannot live in the portable
core. Shared engineering rules, model roles, and skills remain in
`../portable/`.

| Adapter | Host-specific payload |
|---|---|
| `opencode/` | Local config template, agents, commands, prompts, plugins, and themes |
| `claude/` | Claude Code subagents |
| `codex/` | Installation mapping for Codex instructions and shared skills |
| `copilot/` | Installation mapping for Copilot CLI, VS Code instructions, and shared skills |

The installer owns the target paths and symlinks. Adapter documentation must not
duplicate the portable workflow.
