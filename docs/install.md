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
backpack skills                  # manage project skills interactively
backpack find design             # find a curated project skill
backpack add impeccable          # add the UX/UI skill to this project
backpack list                    # list every curated skill and its project status
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
- GitHub Copilot — Terminal · Desktop app

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

## GitHub Copilot

Copilot discovers `~/.copilot/copilot-instructions.md` automatically in the CLI
and desktop app. Backpack also installs RTK's user-level hook under
`~/.copilot/hooks/`, so compatible shell commands are rewritten before they run.
No in-app copy-paste is required.

## Choosing project skills

Cockpit installs only the workflow skills listed in
`cockpit/portable/skills.core`. Specialized skills are project-local:

Run `backpack skills` for the interactive menu, or use the direct commands:

```sh
backpack find frontend               # search the curated catalogue
backpack info react-best-practices   # inspect scope, trigger, boundary, and source
backpack add react-best-practices    # add it to the current project
backpack list                        # see all curated skills with available/installed status
backpack remove react-best-practices # remove it from the current project
```

`backpack add` and `backpack remove` delegate the open skill installation format to the
Skills CLI while Backpack owns the curated names and boundaries. The default is
always the current Git project; the commands never modify Backpack's global core.
Installed skills activate through their descriptions when the request matches.
Adding Impeccable installs its portable skill but does not silently enable its
project hooks; hook activation remains a separate, explicit Impeccable action.

The Cockpit installer removes legacy Backpack-owned global specialized-skill links during
an update, but preserves real directories and links owned by other installers.
Earlier whole-catalogue symlinks are still backed up before migration.

## What is installed

Cockpit uses shared workflow and skill sources with thin host adapters:

```txt
~/.codex/AGENTS.md
~/.copilot/copilot-instructions.md
~/.copilot/hooks/rtk-rewrite.json
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
