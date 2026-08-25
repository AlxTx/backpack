# GitHub Copilot adapter

Copilot CLI and the desktop app consume `~/.copilot/copilot-instructions.md` and
shared skills. Backpack also installs RTK's user-level hook at
`~/.copilot/hooks/rtk-rewrite.json` for automatic command rewriting.

Install only this adapter with:

```sh
backpack install cockpit --copilot
```

No in-app copy-paste is required. Restart GitHub Copilot after installation so
it reloads instructions and hooks.
