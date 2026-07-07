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

It guides the setup in order:

1. runs `bootstrap/doctor.sh` to check that the repo is healthy;
2. shows the symlink plan in dry-run mode, without changing anything;
3. asks for confirmation before applying the plan.

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

By default, the script is interactive: it runs `doctor.sh`, prints the symlink plan, then asks before modifying `~/.config`.

It is for wiring local machine config after clone, not for GitHub authentication.

```sh
bootstrap/install.sh
```

To skip the prompt and apply directly, run:

```sh
bootstrap/install.sh --apply
```

Personal Mac:

```sh
~/dev/perso/backpack/bootstrap/install.sh --personal --apply
```

Client Mac:

```sh
~/dev/perso/backpack/bootstrap/install.sh --client --apply
```

Apply mode:

- backs up existing `~/.config` entries into `~/.config.backup.<timestamp>/`;
- creates symlinks from `~/.config/*` to this repo;
- ensures `~/.config/opencode-profiles/` exists for local provider/model overlays;
- is idempotent when a link already points to the right source.

After applying, restart shells/apps that load config at startup: Fish, OpenCode, Nvim, Karabiner, Ghostty.

## opencode profiles

Backpack contains the portable opencode core only: modes, prompts, commands,
theme, and generic guardrails. Real providers and model choices belong in local
profiles outside the repo:

```txt
~/.config/opencode-profiles/
  perso.jsonc
  chanel.jsonc
```

Templates live in `cockpit/opencode/templates/`.

Rule:

```txt
Backpack decides how to work.
Local profiles decide which providers/models to use.
```

Example launch aliases can be copied from `dotfiles/fish/local.fish.example`.
