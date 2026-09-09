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

## Canonical replacement and recovery

Installation always replaces the selected paths that Backpack manages. It never
merges or silently preserves a divergent local copy:

- OpenCode: the complete `~/.config/opencode/` adapter;
- Codex: `~/.codex/AGENTS.md`, the two named Cockpit validation agents, and the
  shared Cockpit core;
- Claude Code: `~/.claude/rules/backpack.md`, `~/.claude/agents`, and the core;
- GitHub Copilot: the FSH workflow bridge and shared core as explicit
  `/cockpit-*` utilities;
- machine targets: the selected Fish, Starship, Neovim, Ghostty, and Karabiner
  paths.

Authentication, tokens, histories, caches, organization policy, and every path
outside this installation map remain untouched. Non-core skills installed by
another tool also remain outside Backpack's ownership.

An OpenCode install replaces the complete `~/.config/opencode/` adapter with the
canonical Backpack version:

```sh
backpack install cockpit --opencode
```

Before replacing it, Backpack moves the previous directory under the
`~/.config.backup.<timestamp>/` path printed at the end of the installation.
This includes `opencode.json`, package files, dependencies, and local additions.

To make an intentional local `opencode.json` change durable, promote it into
`cockpit/adapters/opencode/opencode.json` and review the repository diff before
running the installer. If installation already replaced it, use the printed
backup as the comparison source. Never promote tokens, secrets, client
endpoints, or client policies into Backpack.

```sh
diff -u cockpit/adapters/opencode/opencode.json ~/.config/opencode/opencode.json
cp ~/.config/opencode/opencode.json cockpit/adapters/opencode/opencode.json
git diff -- cockpit/adapters/opencode/opencode.json
backpack doctor
backpack install cockpit --opencode
```

After an installation, substitute the backed-up `opencode.json` path shown by
the installer for `~/.config/opencode/opencode.json` in this flow.

The same promotion rule applies to every target: compare the backed-up local
file with its source under `cockpit/` or `dotfiles/`, report only the intended
change into Backpack, review the Git diff, then reinstall. Most non-OpenCode
targets are canonical symlinks, so editing through those links already edits the
Backpack source and creates no local divergence.

## GitHub Copilot

Copilot discovers `~/.copilot/copilot-instructions.md` automatically in the CLI
and desktop app. Backpack links that path to its thin FSH workflow bridge and
installs the six namespaced Cockpit skills, whose metadata requires an explicit
`/cockpit-*` invocation in Copilot. Copilot plugins and hooks remain externally
owned.

During migration, Backpack backs up and removes the legacy
`~/.copilot/hooks/rtk-rewrite.json` only when it identifies the former
`rtk hook copilot` command. Other Copilot hooks remain untouched.

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
an update, but leaves non-core paths owned by other installers outside its map.
Earlier whole-catalogue symlinks are still backed up before migration.

## What is installed

Cockpit uses shared workflow and skill sources with thin host adapters:

```txt
~/.codex/AGENTS.md
~/.codex/agents/cockpit-code-review.toml
~/.codex/agents/cockpit-product-qa.toml
~/.copilot/copilot-instructions.md
~/.config/opencode/AGENTS.md
~/.claude/rules/backpack.md
~/.agents/skills/
```

OpenCode receives the complete canonical adapter, including
`/cockpit-brainstorm`, `/cockpit-design`, `/cockpit-review`, and `/cockpit-qa`.
Reinstallation backs up and replaces that managed directory, which removes old
unnamespaced command files instead of preserving aliases. Restart OpenCode after
an update so it reloads commands, instructions, and skills.

Machine installation links the selected Fish, Starship, Neovim, Ghostty, and
Karabiner configuration from this repository. Existing replaced entries are
backed up under `~/.config.backup.<timestamp>/`.

After installation, restart applications that load configuration at startup.
OpenCode must be restarted after updating its adapter, commands, agents, or
skills.
