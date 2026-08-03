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

Clone the repository wherever you keep personal projects:

```sh
mkdir -p ~/dev/perso
git clone git@github.com:AlxTx/backpack.git ~/dev/perso/backpack
cd ~/dev/perso/backpack
```

Run the interactive installer. It validates the repository, previews the plan,
and asks before changing local configuration:

```sh
bootstrap/install.sh
```

OpenCode is selected by default. You can instead choose Codex, Claude Code,
GitHub Copilot, the complete AI stack, shell, editor, terminal UI, or everything.
The installer uses `gum` when available and falls back to a numbered menu.
Uppercase `~/Dev` casing is also tolerated on macOS.

## Common commands

| Need | Command |
|---|---|
| Validate the repository only | `bootstrap/doctor.sh` |
| Preview and choose interactively | `bootstrap/install.sh` |
| Install OpenCode directly (default target) | `bootstrap/install.sh --apply` |
| Install everything on a personal Mac | `bootstrap/install.sh --only all --personal --apply` |
| Install everything on a client Mac | `bootstrap/install.sh --only all --client --apply` |
| Install the complete AI stack | `bootstrap/install.sh --only ai --apply` |
| Install Codex only | `bootstrap/install.sh --only codex --apply` |
| Install Claude Code only | `bootstrap/install.sh --only claude --apply` |
| Install GitHub Copilot instructions only | `bootstrap/install.sh --only copilot --apply` |
| Replace an existing OpenCode install | `bootstrap/install.sh --only opencode --replace --apply` |
| Refresh OpenCode without replacing local providers | `bootstrap/install.sh --only opencode --update --apply` |

`--apply` skips the confirmation prompt. The `ai`, `codex`, `claude`,
`opencode`, and `all` targets install [`rtk`](https://github.com/rtk-ai/rtk)
through Homebrew when needed; use `--without-rtk` to opt out. The Copilot-only
target does not install RTK.

## Shared AI workflow

The canonical rules and skills live in `cockpit/portable/`. Host-specific files
live under `cockpit/adapters/<host>/`. The installer combines the selected
adapter with the portable core and links them into the locations consumed by
that host:

```txt
Codex CLI/Desktop  ~/.codex/AGENTS.md
GitHub Copilot CLI ~/.copilot/copilot-instructions.md
Copilot in VS Code ~/.copilot/instructions/backpack.instructions.md
OpenCode           ~/.config/opencode/AGENTS.md
Claude Code        ~/.claude/rules/backpack.md
Shared skills      ~/.agents/skills
```

Copilot CLI and VS Code therefore receive the personal workflow without adding
files to client repositories. Repository-level `AGENTS.md` and
`.github/copilot-instructions.md` files remain project truth and can add
client-specific constraints. GitHub-hosted Copilot agents and code review need
those repository-level instructions; Backpack does not create or commit them
automatically.

OpenCode is the default target and the exception to the symlink-only model: its
adapter is copied once to `~/.config/opencode/`. Local provider and model choices
stay in `~/.config/opencode/opencode.json` and are preserved by `--update`.

## Safety and profiles

Installation is non-destructive by default: it previews first, backs up replaced
entries under `~/.config.backup.<timestamp>/`, and leaves matching links alone.
Interactive installation asks whether an existing OpenCode configuration should
be kept or replaced; direct apply keeps it unless `--replace` is passed.
On client machines, use `--client` and keep providers, tokens, endpoints,
policies, and mission notes outside Backpack.

After installation, restart applications that load configuration at startup.
OpenCode must be restarted after adapter or skill updates; Copilot CLI can reload
skills with `/skills reload`.

See [installation details](docs/install.md) for every option and
[the host-agnostic AI workflow](docs/ai-workflow.md) for host boundaries.
