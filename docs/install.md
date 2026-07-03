# Install

Phase 1 keeps this backpack separate from the active system config.

## Clone

On a new machine, set up GitHub SSH first. `bootstrap/install.sh` is inside this repo, so it cannot help until cloning already works.

Default clone command, if `git@github.com` is already configured with the right personal SSH key:

```sh
git clone git@github.com:AlxTx/backpack.git ~/perso/backpack
```

If the machine has multiple GitHub SSH identities, or if `git@github.com` is not configured, use the explicit personal SSH host instead:

```sh
git clone git@github-perso:AlxTx/backpack.git ~/perso/backpack
```

See `docs/git-identity.md` for the difference between SSH authentication and Git commit identity.

On the current Mac, `github-perso` is required because `git@github.com` does not authenticate.

Quick check:

```sh
ssh -T git@github.com
ssh -T git@github-perso
```

At least one of these must authenticate as `AlxTx` before cloning.

## Scripts

### `bootstrap/doctor.sh`

Checks that the backpack is structurally valid:

- expected folders/files exist;
- `fish_variables` is not versioned;
- Git remote targets `AlxTx/backpack`.

Run it after cloning or after structural changes:

```sh
~/perso/backpack/bootstrap/doctor.sh
```

### `bootstrap/install.sh`

By default, the script is non-destructive: it prints the symlink plan and does **not** modify `~/.config`.

It is for wiring local machine config after clone, not for GitHub authentication.

```sh
~/perso/backpack/bootstrap/install.sh
```

To apply the wiring, run:

```sh
~/perso/backpack/bootstrap/install.sh --apply
```

Apply mode:

- backs up existing `~/.config` entries into `~/.config.backup.<timestamp>/`;
- creates symlinks from `~/.config/*` to `~/perso/backpack/*`;
- is idempotent when a link already points to the right source.

After `--apply`, restart shells/apps that load config at startup: Fish, OpenCode, Nvim, Karabiner, Ghostty.
