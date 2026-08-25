# GitHub Copilot adapter

Copilot CLI consumes `~/.copilot/copilot-instructions.md` and shared skills.
The GitHub Copilot App automatically sees the same skills, but its global
instructions are stored in the app settings rather than a documented local file.

Install only this adapter with:

```sh
backpack install cockpit --copilot
```

After a successful install, Backpack copies the portable workflow to the
clipboard and shows where to paste it in GitHub Copilot App. To recopy it after a
later Backpack update:

```sh
sh bootstrap/copilot-app-instructions.sh --copy
```
