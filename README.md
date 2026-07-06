# Backpack

Portable personal working environment: cockpit, dotfiles, and durable learning memory.

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

## Status

Phase 1 is non-destructive: this repo is built in parallel to the active `~/.config` setup.
System wiring via symlinks comes later.

## Quick start

Clone the repo wherever you keep your projects:

```sh
git clone git@github.com:AlxTx/backpack.git
cd backpack
```

Then run the installer:

```sh
bootstrap/install.sh
```

It guides you through three steps:

1. runs `bootstrap/doctor.sh` to check that the repo is healthy;
2. shows the install plan in dry-run mode, without changing anything;
3. asks for confirmation before backing up existing `~/.config` entries and creating symlinks.

### When to use each command

Use `doctor.sh` after cloning, or after changing the repo structure. It only validates that expected files exist and that the repo looks healthy.

```sh
bootstrap/doctor.sh
```

Use `install.sh` for normal setup. It checks, previews, then prompts before applying.

```sh
bootstrap/install.sh
```

Use `install.sh --apply` only when you want to skip the prompt, for example in a scripted setup.

```sh
bootstrap/install.sh --apply
```
