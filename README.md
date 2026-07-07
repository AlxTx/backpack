# Backpack

Portable macOS personal working environment: cockpit, dotfiles, and durable
learning memory.

## Structure

```txt
bootstrap/   setup and validation scripts
cockpit/     AI/dev workflow configuration, currently OpenCode
memory/      durable personal learning: craft, AI, concepts, books, playbooks
```

## Boundaries

- `backpack/memory` is personal, durable, and reusable.
- Client mission notes live outside this repo.
- Project truth lives in each project repo (`README.md`, `AGENTS.md`, `docs/`).
- Secrets, SSH keys, tokens, client-specific certs, and local state are not committed.
- Client-specific opencode providers/models are local machine config and are not committed.

## Status

Install is non-destructive by default. `--apply` backs up existing config before
creating symlinks.

## Usage

```sh
# check
~/dev/perso/backpack/bootstrap/doctor.sh

# personal Mac
~/dev/perso/backpack/bootstrap/install.sh --personal --apply

# client Mac
~/dev/perso/backpack/bootstrap/install.sh --client --apply
```

OpenCode uses Backpack as a one-shot portable core. On a new machine, the
installer copies `cockpit/opencode/` to `~/.config/opencode/` if it does not
exist yet. Real providers/models then stay local in the effective OpenCode
config:

```txt
~/.config/opencode/opencode.json
```

For example, on a client Mac, run the installer once, edit
`~/.config/opencode/opencode.json` to select the client LLM provider/models,
then launch `opencode` normally.

## Quick start

Clone the repo wherever you keep your projects:

```sh
mkdir -p ~/dev/perso
git clone git@github.com:AlxTx/backpack.git ~/dev/perso/backpack
cd ~/dev/perso/backpack
```

On macOS, an existing `~/Dev` directory may preserve uppercase casing even when
you type `~/dev`. That is OK; Backpack scripts resolve their real path, and Git
identity examples include both `~/dev/perso` and `~/Dev/perso`.

Then run the installer:

```sh
bootstrap/install.sh
```

The default mode is interactive: choose OpenCode, shell, editor, terminal/UI, or
everything. If `gum` is installed, Backpack uses a modern selectable prompt. On
a fresh Mac with Homebrew but without `gum`, Backpack offers to install it; if
that is skipped or unavailable, it falls back to a plain numbered menu. If an
OpenCode config already exists locally, Backpack asks whether to keep it or back
it up before installing a fresh copy.

It guides you through three steps:

1. runs `bootstrap/doctor.sh` to check that the repo is healthy;
2. asks what you want to install when no target is provided;
3. shows the install plan in dry-run mode, without changing anything;
4. asks for confirmation before creating local config entries and symlinks.

OpenCode is copied once rather than symlinked, so editing
`~/.config/opencode/opencode.json` on a client machine does not modify
Backpack.

To refresh the local OpenCode core later without touching local models/providers:

```sh
bootstrap/install.sh --only opencode --update --apply
```

### When to use each command

Use `doctor.sh` after cloning, or after changing the repo structure. It only validates that expected files exist and that the repo looks healthy.

```sh
bootstrap/doctor.sh
```

Use `install.sh` for normal setup. It checks, previews, then prompts before applying.

```sh
bootstrap/install.sh
```

Use `install.sh --apply` only when you want to skip the prompt, for example in a scripted setup. Add `--personal` on a personal Mac or `--client` on a client Mac.

```sh
bootstrap/install.sh --personal --apply
bootstrap/install.sh --client --apply
```
