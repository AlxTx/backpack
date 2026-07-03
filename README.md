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

Before cloning on a new machine, GitHub SSH authentication must already work.
`install.sh` cannot fix clone/auth problems because it runs after the repo exists locally.

```sh
git clone git@github.com:AlxTx/backpack.git ~/perso/backpack
~/perso/backpack/bootstrap/doctor.sh
```

If the machine has multiple GitHub SSH identities, or if `git@github.com` is not configured, clone with the explicit personal host instead:

```sh
git clone git@github-perso:AlxTx/backpack.git ~/perso/backpack
```

`bootstrap/install.sh` is non-destructive by default: it only prints the symlink plan.
Run `bootstrap/install.sh --apply` to backup existing `~/.config` entries and wire this backpack through symlinks.
