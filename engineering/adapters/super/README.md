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
setting. User layouts remain in Super.

`backpack install engineering --super` creates or updates five global commands
from the [portable prompt files](commands/) through Super's `sc` CLI:
`🧭 Kickoff`, `👥 Team build`, `⚖️ Validate`, `📚 Learn`, and
`🔎 Pattern scan`. Reinstalling renames the earlier `Backpack · ...` commands
by ID, updates their prompts, and does not create another copy. It reports
an existing duplicate instead of guessing which one to replace. Backpack owns
their prompt, current-chat launch, Chat UI view, and Auto-submit setting; it
preserves each command's local provider, model, reasoning, and icon overrides.
The emoji lives in the visible command name, so an icon override cannot hide
the action cue.
Other Super commands are untouched. Super must be installed; Backpack starts it
if needed so the CLI can synchronize global App Settings. An explicit
`SUPER_CONFIG_DIR` override redirects settings files only, so it skips command
synchronization rather than writing to the wrong Super profile.

`👥 Team build` explicitly requests Super orchestration and
permits delegation only for bounded independent work. A small task can stay
with the lead alone. Backpack supplies the Build and Validate contract; Super
supplies session, team, and layout mechanics. Auto-submit is off so the scoped
task can be reviewed before launch. `⚖️ Validate` separately
offers read-only Code Review and Product QA; no duplicate parallel-review
command is needed.

Super's provider permission mode still applies to every session. If `sc`
capabilities or permissions are unavailable, the lead reports that condition
instead of claiming an orchestrated run. The command stays in the current
worktree and grants no Git delivery or deployment authority. A different
worktree or branch needs a separate explicit request.

For a new or ongoing project, open its folder in Super, share the idea, brief,
decisions, and relevant work in a chat, then run `🧭 Kickoff`
from the worktree action card or the Command Palette. Ask it to resume from the
current state and show a progress checklist when work has already started.
Answer the next question in the same chat. A greenfield project needs no
existing codebase; a change to an existing product follows brownfield framing.
Continue until Backpack proposes the next deliverable and expected proof, then
request Build when ready. Ask for a project-owned Markdown tracker in a separate
Build request if the checklist should persist across chats.

For a complete first installation, install the provider adapters and Super in
one pass:

```sh
backpack install engineering --all-hosts
```

To refresh only Super preferences and commands afterward, use:

```sh
backpack install engineering --super
```

Restart Super after installation so the desktop app reloads the merged files.
