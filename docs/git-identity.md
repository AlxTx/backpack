# Git and SSH identity

There are two separate concerns:

```txt
SSH = which key/account is used to authenticate to the remote
Git = which author name/email is written into commits
```

Both must be correct.

## SSH remote identity

SSH controls which key/account authenticates to GitHub.

Default remote syntax is fine when the machine has only one relevant GitHub identity:

```txt
git@github.com:AlxTx/backpack.git
```

If the machine has multiple GitHub identities, use an explicit SSH host for personal repositories:

```txt
git@github-perso:AlxTx/backpack.git
```

Expected SSH template:

```sshconfig
Host github-perso
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_alxtx
  IdentitiesOnly yes
```

Client repositories keep the client-provided Git/SSH configuration. Backpack does not install or version client identity.

The important rule is not the host name itself; it is that personal repos authenticate with the personal key/account, and client repos authenticate with the client-approved setup.

## Git commit identity

Use Git `includeIf` to select identity by local folder.

Recommended global `~/.gitconfig` shape:

```ini
[includeIf "gitdir:~/perso/"]
  path = ~/.gitconfig-perso
```

Personal `~/.gitconfig-perso` shape:

```ini
[user]
  name = Alexis Estrade
  email = YOUR_PERSONAL_EMAIL@example.com
```

Client/work Git identity is intentionally not managed by backpack. Use the client-provided Git configuration for client repos.

Recommended local boundary:

```txt
~/perso/   personal repos and backpack
~/client/  client repos and mission context
```

Never commit SSH keys, tokens, client emails, or client-specific Git config.

Templates live in:

```txt
dotfiles/git/gitconfig.example
dotfiles/git/gitconfig-perso.example
dotfiles/ssh/config.example
```
