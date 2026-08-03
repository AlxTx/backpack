# Install

Backpack targets macOS only. Phase 1 keeps this backpack separate from the active
system config until `--apply` is used.

## Clone

Clone the repo wherever you keep your projects:

```sh
mkdir -p ~/dev/perso
git clone git@github.com:AlxTx/backpack.git ~/dev/perso/backpack
cd ~/dev/perso/backpack
```

On macOS, an existing `~/Dev` directory may preserve uppercase casing even when
you type `~/dev`. That is OK; Backpack scripts resolve their real path, and Git
identity examples include both `~/dev/perso` and `~/Dev/perso`.

If cloning fails, fix GitHub access first, then rerun the clone command. The install scripts live inside this repo, so they only run after the repo exists locally.

## Install

Run the installer from the repo root:

```sh
bootstrap/install.sh
```

If [`gum`](https://github.com/charmbracelet/gum) is installed, the interactive
flow uses selectable prompts. On a fresh Mac with Homebrew but without `gum`,
Backpack offers to install it. If that is skipped or unavailable, the installer
falls back to a plain numbered menu.

It guides the setup in order:

1. runs `bootstrap/doctor.sh` to check that the repo is healthy;
2. asks what you want to install when no target is provided;
3. shows the install plan in dry-run mode, without changing anything;
4. asks for confirmation before applying the plan.

## Check only

Run the structural check after cloning or after structural changes:

```sh
bootstrap/doctor.sh
```

## Scripts

### `bootstrap/doctor.sh`

Checks that the backpack is structurally valid:

- expected folders/files exist;
- `fish_variables` is not versioned;
- Git remote targets `AlxTx/backpack`.

Run it from the repo root:

```sh
bootstrap/doctor.sh
```

### `bootstrap/install.sh`

By default, the script is interactive: it runs `doctor.sh`, prints the install plan, then asks before modifying `~/.config`.

OpenCode is the default selection. In direct apply mode, omitting `--only`
therefore installs OpenCode rather than the complete Backpack configuration:

```sh
bootstrap/install.sh --apply
```

It is for wiring local machine config after clone, not for GitHub authentication.

```sh
bootstrap/install.sh
```

To skip the prompt and apply directly, run:

```sh
bootstrap/install.sh --apply
```

To install only one part from Backpack, use `--only`:

```sh
bootstrap/install.sh --only ai
bootstrap/install.sh --only codex
bootstrap/install.sh --only claude
bootstrap/install.sh --only copilot
bootstrap/install.sh --only opencode
bootstrap/install.sh --only shell
bootstrap/install.sh --only editor
bootstrap/install.sh --only terminal
```

Every AI host has a standalone target. `--only codex`, `--only claude`,
`--only copilot`, and `--only opencode` install the selected adapter plus the
portable workflow and shared skills. `--only ai` installs all four adapters.
Codex CLI/Desktop, Claude Code CLI/Desktop, and OpenCode CLI/Desktop share those
local configurations. GitHub Copilot CLI is configured locally, while GitHub
Copilot App requires one additional UI step because its global instructions are
stored by the app. After a successful install, Backpack prints the complete
block to copy and paste. To display it again later:

```sh
sh bootstrap/copilot-app-instructions.sh --copy
```

Paste the result in GitHub Copilot App → Settings → General → Global
instructions. OpenCode adds its modes, commands, permissions, and defaults;
Claude adds its subagents; Codex maps the portable files to its native location.

RTK is installed by default for the `ai`, `codex`, `claude`, `opencode`, and
`all` targets. The explicit complete-AI-stack command is:

```sh
bootstrap/install.sh --only ai --apply
```

This installs the [`rtk`](https://github.com/rtk-ai/rtk) binary through Homebrew
when necessary, installs the OpenCode rewrite plugin, and configures the Claude
Code hook. Codex and Copilot inherit the portable shell rule. Use
`--without-rtk` to opt out. Copilot-only and shell-only installs do not install
RTK.

If `~/.config/opencode` already exists, interactive mode asks whether to keep it
or back it up and install a fresh copy. Non-interactive apply mode keeps it by
default; use `--replace` to back it up and copy OpenCode again:

```sh
bootstrap/install.sh --only opencode --replace --apply
```

To update the local OpenCode core from Backpack without overwriting local
providers/models, use `--update`:

```sh
bootstrap/install.sh --only opencode --update --apply
```

This backs up `~/.config/opencode`, then refreshes adapter files such as
`agents/`, `prompts/`, `commands/`, `plugins/`, `themes/`, `README.md`, and
`tui.json`. It
intentionally keeps `~/.config/opencode/opencode.json` untouched because that
file may contain machine/client LLM settings. Machine-local extensions and
dependencies (`package.json`, its lockfile, `node_modules`, and `.claude`) are
preserved when present. Shared guidance and skills remain linked to
`cockpit/portable/`.

Personal Mac:

```sh
~/dev/perso/backpack/bootstrap/install.sh --only all --personal --apply
```

Client Mac:

```sh
~/dev/perso/backpack/bootstrap/install.sh --only all --client --apply
```

Apply mode:

- backs up existing symlinked `~/.config` entries into `~/.config.backup.<timestamp>/`;
- creates symlinks from most `~/.config/*` entries to this repo;
- links the shared AI workflow into Codex, GitHub Copilot, OpenCode, Claude Code,
  and `~/.agents/skills`;
- copies `cockpit/adapters/opencode/` once to `~/.config/opencode/` when it is missing;
- is idempotent when a link already points to the right source.

After applying, restart shells/apps that load config at startup: Fish, OpenCode,
Nvim, Karabiner, Ghostty. OpenCode must be restarted after updating agents,
commands, prompts, or skills; it loads those files at startup.

## AI workflow and OpenCode local config

Backpack stores the canonical workflow in `cockpit/portable/`, keeps thin
host-specific payloads in `cockpit/adapters/`, and links both to the personal
locations consumed by the selected host:

```txt
~/.codex/AGENTS.md
~/.copilot/copilot-instructions.md
~/.copilot/instructions/backpack.instructions.md
~/.config/opencode/AGENTS.md
~/.claude/rules/backpack.md
~/.agents/skills/
```

The two Copilot links cover Copilot CLI and personal instruction files in VS
Code. Shared agent skills are already discovered through `~/.agents/skills`.
Client repository instructions remain in that repository's `AGENTS.md` or
`.github/copilot-instructions.md`; the installer never creates them.

The OpenCode adapter is copied once to the real OpenCode config directory:

```txt
~/.config/opencode/
  AGENTS.md -> backpack/cockpit/portable/AGENTS.md
  opencode.json
  agents/
  prompts/
  commands/
```

Real providers and model choices belong in that local machine file. On a client
Mac, edit `~/.config/opencode/opencode.json` after bootstrap and launch
`opencode` normally.

Rule:

```txt
Backpack decides how to work.
Local machine config decides which providers/models to use.
```
