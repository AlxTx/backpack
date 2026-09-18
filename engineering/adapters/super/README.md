# Super adapter

Backpack treats super.engineering as the visual control plane for Backpack
Engineering. This adapter carries a deliberately small, personal configuration
across Macs while Super continues to own its runtime state.

The installer recursively merges `settings.json` and `chat-defaults.json` into
`~/.super.engineering/`. On upgraded installations, Super's official
`sc migrate-data` flow keeps the original data in `~/.superconductor/` and
publishes the new name as an alias to it. Backpack validates that relationship;
it never moves, renames, merges, or deletes either profile. The merge updates
only keys present in this adapter and preserves all other local values.

Portable configuration includes:

- visual and editor preferences;
- safe execution defaults;
- Codex as the default engine;
- reasoning defaults without pinned model IDs;
- agent orchestration enabled.

Backpack intentionally excludes provider profiles, tokens, enabled-provider
lists, model routing, workspaces, projects, worktrees, layouts, sessions,
history, databases, caches, sockets, window state, and every Copilot-owned
setting. Global commands and user layouts are currently left in Super because
the installed CLI exposes CRUD for commands and capture/apply for layouts, but
does not expose a stable declarative import format for both.

Install or refresh it with:

```sh
backpack install engineering --super
```

Restart Super after installation so the desktop app reloads the merged files.
