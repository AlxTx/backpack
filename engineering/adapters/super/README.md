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

## App-managed orchestration

`agent_orchestration` only makes Super's app-managed orchestration available.
It does not launch agents or grant standing permission. In a Super Chat UI,
explicitly ask to "orchestrate" a task, name providers or models, or request
visible tabs, panes, or sessions. Super then injects the current `sc` contract
into the active provider and that provider selects the appropriate workflow.

For independent parallel roles, the provider may use `sc team run`; for a
strict handoff such as design → implementation → review, it uses labeled
sessions and waits between phases. A Team workflow is provider-neutral: the
lead can launch locally enabled providers such as Codex and OpenCode, including
a mixed-provider team. Provider profiles, model routing, worktrees, and layout
remain local Super state and are not managed by Backpack.

Use the installed `sc instructions orchestration` and `sc help team` as the
source of truth for the current app version. Backpack does not install legacy `superset-*`
orchestration skills or `superset` CLI wrappers.

Backpack intentionally excludes provider profiles, tokens, enabled-provider
lists, model routing, workspaces, projects, worktrees, layouts, sessions,
history, databases, caches, sockets, window state, and every Copilot-owned
setting. Global commands and user layouts are currently left in Super because
the installed CLI exposes CRUD for commands and capture/apply for layouts, but
does not expose a stable declarative import format for both.

Personal Backpack actions can be exposed as global custom commands:
`Backpack · Project kickoff`, `Backpack · Validate delivery`,
`Backpack · Learn`, and `Backpack · Pattern scan`. They use the session's
provider by default and launch the corresponding portable workflow. These
commands live in Super's App Settings; `backpack install engineering --super`
does not create or synchronize them.

For a new project, open its folder in Super, share the idea or brief in a chat,
then run `Backpack · Project kickoff` from the worktree action card or the
Command Palette. Answer the next question in the same chat. A greenfield project
needs no existing codebase; a change to an existing product follows brownfield
framing. Continue until Backpack proposes the first deliverable and expected
proof, then request Build when ready.

Install or refresh it with:

```sh
backpack install engineering --super
```

Restart Super after installation so the desktop app reloads the merged files.
