# GitHub Copilot adapter

Copilot CLI consumes `~/.copilot/copilot-instructions.md`; Copilot in VS Code
consumes `~/.copilot/instructions/backpack.instructions.md`. Both point to the
portable workflow, and personal skills remain in `~/.agents/skills`.

Install only this adapter with:

```sh
bootstrap/install.sh --only copilot --apply
```
