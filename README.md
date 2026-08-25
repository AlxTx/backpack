# Backpack

Portable macOS personal working environment: cockpit, dotfiles, and durable
learning memory.

## Structure

```txt
bootstrap/           setup and validation scripts
cockpit/portable/    host-agnostic AI workflow and skills
cockpit/adapters/    thin Codex, Claude, Copilot, and OpenCode adapters
memory/              durable personal learning: craft, AI, concepts, books, playbooks
```

## Boundaries

- `backpack/memory` is personal, durable, and reusable.
- Client mission notes live outside this repo.
- Project truth lives in each project repo (`README.md`, `AGENTS.md`, `docs/`).
- Secrets, SSH keys, tokens, client-specific certs, and local state are not committed.
- Client-specific providers and models remain in local machine configuration.

## Quick start

Clone the repository wherever you keep your projects, enter it, then launch the
menu:

```sh
git clone git@github.com:AlxTx/backpack.git
cd backpack
./backpack
```

`./backpack` means “run the `backpack` file from this folder”. The first
installation links the command into `~/.local/bin`; afterward, when that folder
is on `PATH`, use `backpack` from anywhere.

The menu validates the repository, previews interactive plans, and asks before
changing local configuration.

The menu clearly separates **Cockpit** — the portable workflow used inside AI
tools — from this Mac's shell, editor, and terminal configuration. The installer
uses arrow-key menus when `gum` is available and falls back to a numbered menu.

## Common commands

| Need | Command |
|---|---|
| Open the main menu | `backpack` |
| Choose what to install | `backpack install` |
| Validate the repository only | `backpack doctor` |
| Show installed components | `backpack status` |
| Install everything on a personal Mac | `backpack install everything --personal` |
| Install everything on a client Mac | `backpack install everything --client` |
| Install Cockpit for every AI tool | `backpack install cockpit --all-hosts` |
| Install Cockpit for Codex | `backpack install cockpit --codex` |
| Install Cockpit for Claude Code | `backpack install cockpit --claude` |
| Install Cockpit for GitHub Copilot | `backpack install cockpit --copilot` |
| Copy instructions for GitHub Copilot App again | `sh bootstrap/copilot-app-instructions.sh --copy` |
| Update Cockpit for OpenCode | `backpack install cockpit --opencode` |
| Replace an existing OpenCode adapter | `backpack install cockpit --opencode --replace` |
| Install personal skills without optional rule sets | `backpack install cockpit --all-hosts --skills core` |
| Install instructions and agents without skills | `backpack install cockpit --all-hosts --skills none` |

A direct target applies immediately; use `--dry-run` for a read-only preview.
Applicable Cockpit targets install [`rtk`](https://github.com/rtk-ai/rtk)
through Homebrew when needed; use `--without-rtk` to opt out.

## Shared AI workflow

The canonical rules and skills live in `cockpit/portable/`. Host-specific files
live under `cockpit/adapters/<host>/`. The installer combines the selected
adapter with the portable core.

An interactive install asks which skill set to install, and the answer applies to
every selected host: Codex, Claude Code, GitHub Copilot, and OpenCode all receive
the same set. `all` installs everything, `core` installs personal doctrine only
and skips the vendored third-party rule sets listed in
`cockpit/portable/skills.optional`, and `none` installs instructions and agents
without any skill. Use `--skills` to choose non-interactively; it defaults to
`all`.

| Host | CLI | Desktop app |
|---|---|---|
| Codex | `~/.codex/AGENTS.md` | Uses the same instruction source |
| Claude Code | `~/.claude/rules/backpack.md`, agents, and skills | Code tab shares the same local configuration |
| OpenCode | `~/.config/opencode/` | Uses the same configuration as CLI and TUI |
| GitHub Copilot | `~/.copilot/copilot-instructions.md` and `~/.agents/skills` | Skills are shared; paste the workflow into App global instructions |

GitHub Copilot App is the one exception: its global instructions have no
documented local file. A successful Copilot install copies the instructions to
the clipboard and shows where to paste them. If the portable workflow is updated
later, recopy it with:

```sh
sh bootstrap/copilot-app-instructions.sh --copy
```

Repository-level instructions remain project truth and can add client-specific
constraints. Backpack never creates or commits them automatically.

## Visible Cockpit activity

For a non-trivial task, Cockpit-compatible hosts expose the active Cockpit phase,
then any skill, agent, plugin, or integration actually activated. Native host
events are preferred; otherwise Backpack emits a compact one-line fallback such
as `Cockpit · skill loaded · code-first-product-design`. It never duplicates an
activation the host already displays. This makes the workflow visible without
exposing private model reasoning or producing a log for every shell command.
After updating Backpack, restart the host; for GitHub Copilot App, copy the
refreshed global-instructions block again.

OpenCode is the exception to the symlink-only model: Backpack updates its adapter
in `~/.config/opencode/`. Local provider and model choices stay in
`~/.config/opencode/opencode.json` and are preserved by normal updates.

## Safety and profiles

Interactive installation previews first; direct targets apply immediately.
Backpack backs up replaced entries under `~/.config.backup.<timestamp>/`, leaves
matching links alone, and preserves local OpenCode configuration during normal
updates. `--replace` requests a fresh OpenCode adapter explicitly.
On client machines, use `--client` and keep providers, tokens, endpoints,
policies, and mission notes outside Backpack.

After installation, restart applications that load configuration at startup.
OpenCode must be restarted after adapter or skill updates; Copilot CLI can reload
skills with `/skills reload`.

See [installation details](docs/install.md) for every option and
[the host-agnostic AI workflow](docs/ai-workflow.md) for host boundaries.
