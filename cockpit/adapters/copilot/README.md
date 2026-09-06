# GitHub Copilot adapter

Copilot CLI and the desktop app consume `~/.copilot/copilot-instructions.md` and
shared skills. Backpack also installs RTK's user-level hook at
`~/.copilot/hooks/rtk-rewrite.json` for automatic command rewriting.

The desktop app can therefore run the same **Plan → Build → Validate → Learn**
loop as the other hosts. `cockpit-validate`, `cockpit-learn`, and
`cockpit-start-work` are portable skills rather than Copilot-specific commands.
Use Copilot's native Plan, Interactive, or Autopilot surface; Cockpit supplies
the lifecycle and delivery gates without recreating that UI.

## Model selection

Copilot availability depends on the account and organization policy, so the
adapter does not pin a model. Cockpit applies the semantic routing from
`cockpit/portable/MODELS.md` when it can identify the active model. If another
available model is materially safer or safely cheaper, Cockpit asks before work
and makes the manual step explicit: select it in Copilot, then answer `yes` once
active, or `no` to continue unchanged. It never assumes that accepting the
recommendation changed the model.

Copilot App is the preferred candidate when a professional Copilot seat should
carry model consumption. Validate on real work that the available organization
policy and credit budget cover the intended usage, and compare its native agent
visibility and browser feedback loop with Codex before selecting it as the sole
desktop host.

Installation replaces these Backpack-managed paths and backs up conflicts;
Copilot account data, organization policy, histories, and caches remain
untouched.

Install only this adapter with:

```sh
backpack install cockpit --copilot
```

No in-app copy-paste is required. Restart GitHub Copilot after installation so
it reloads instructions and hooks.
