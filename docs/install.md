# Install

Backpack targets macOS. It distributes Cockpit and the personal machine
configuration; Cockpit is the workflow used inside supported AI tools.

## First installation

Clone the repository, then start the Backpack menu:

```sh
git clone git@github.com:AlxTx/backpack.git
cd backpack
./backpack
```

The first installation adds `backpack` to `~/.local/bin`. Later, if that
directory is on `PATH`, the command can be run from anywhere.

`backpack` opens the main menu. `backpack install` opens the installation menu.
Both use selectable prompts when `gum` is available and fall back to numbered
menus otherwise. Interactive installation previews the plan and asks for
confirmation before changing local configuration.

## Commands

```sh
backpack                         # main menu
backpack install                 # choose what to install
backpack install cockpit        # choose an AI tool
backpack install machine        # choose machine configuration
backpack install everything --personal
backpack doctor                  # validate the repository
backpack status                  # show what is installed
```

Select a Cockpit host directly when no menu is wanted:

```sh
backpack install cockpit --opencode
backpack install cockpit --codex
backpack install cockpit --claude
backpack install cockpit --copilot
backpack install cockpit --all-hosts
```

The host menu describes the affected surfaces:

- OpenCode — Terminal · Desktop app · GitHub Action
- Codex — Terminal · Desktop app
- Claude Code — Terminal · Desktop app (Code tab)
- GitHub Copilot — Terminal · Desktop app (one manual step)

Select machine configuration directly with `--shell`, `--editor`, `--terminal`,
or `--all-machine`. A direct target applies immediately; add `--dry-run` for a
read-only preview. RTK is included for applicable Cockpit hosts unless
`--without-rtk` is passed.

## Existing OpenCode configuration

The normal OpenCode install updates Backpack-owned agents, prompts, commands,
plugins, themes, and documentation. It backs up the existing directory and
preserves local `opencode.json`, package files, dependencies, and `.claude`
extensions. No separate update command or manual agent merge is needed.

Use `--replace` only when you intentionally want a fresh OpenCode adapter:

```sh
backpack install cockpit --opencode --replace
```

Local providers, models, tokens, endpoints, and client policies belong in the
machine-local OpenCode configuration and must not be committed to Backpack.

## GitHub Copilot App

Copilot CLI instructions and shared skills are installed automatically. The
desktop app requires one manual step because its global instructions are stored
in the app. Backpack copies the instructions to the clipboard and shows the
destination after installation. Copy them again with:

```sh
sh bootstrap/copilot-app-instructions.sh --copy
```

Paste it in GitHub Copilot App → Settings → General → Global instructions.

## Choosing a skill set

Skills are one shared catalogue, so the choice is made once and applies to every
selected host. An interactive install asks for it after the target; a
non-interactive install defaults to `all`.

```sh
backpack install cockpit --all-hosts --skills all   # everything (default)
backpack install cockpit --all-hosts --skills core  # personal doctrine only
backpack install cockpit --all-hosts --skills none  # instructions and agents only
```

`core` skips the skills listed in `cockpit/portable/skills.optional`. That file
holds the vendored third-party rule sets, which are worth installing on a machine
that writes React and are dead weight on one that does not. Anything absent from
the manifest is core and is always installed, so adding a skill never requires
touching the installer.

Each selected skill is linked individually into `~/.agents/skills` for Codex,
Copilot, and OpenCode, and into `~/.claude/skills` for Claude Code. Earlier
releases linked the whole catalogue as a single symlink; the installer detects
that layout, backs it up, and replaces it with a directory of per-skill links.

Reinstall with a different set at any time — it relinks what is selected and
backs up whatever it replaces.

## What is installed

Cockpit uses shared workflow and skill sources with thin host adapters:

```txt
~/.codex/AGENTS.md
~/.copilot/copilot-instructions.md
~/.copilot/instructions/backpack.instructions.md
~/.config/opencode/AGENTS.md
~/.claude/rules/backpack.md
~/.agents/skills/
```

Machine installation links the selected Fish, Starship, Neovim, Ghostty, and
Karabiner configuration from this repository. Existing replaced entries are
backed up under `~/.config.backup.<timestamp>/`.

After installation, restart applications that load configuration at startup.
OpenCode must be restarted after updating its adapter, commands, agents, or
skills.
