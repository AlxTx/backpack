# GitHub Copilot adapter

Copilot CLI and the desktop app receive the FSH workflow bridge from
`copilot-instructions.md` in this adapter and discover Cockpit's shared skills.
Backpack does not install a Copilot hook.

Every `cockpit-*` skill is an explicit utility in Copilot: invoke it with its
full `/cockpit-*` name. Copilot must not select these skills automatically, and
control returns to the externally owned workflow after the requested utility
finishes. Other hosts keep Cockpit's normal automatic routing.

## Model selection

Copilot availability depends on the account and organization policy, so the
adapter does not pin a model. Cockpit applies the semantic routing from
`cockpit/portable/MODELS.md` when it can identify the active model. If another
available model is materially safer or safely cheaper, Cockpit asks before work
and makes the manual step explicit: select it in Copilot, then answer `yes` once
active, or `no` to continue unchanged. It never assumes that accepting the
recommendation changed the model.

Copilot App can use a client-owned workflow while retaining the portable
Cockpit utilities for focused, user-requested operations.

Installation links the FSH workflow bridge and shared Cockpit skills. Copilot
hooks, plugins, account data, organization policy, histories, and caches remain
untouched.

Install only this adapter with:

```sh
backpack install cockpit --copilot
```

Reload Copilot skills after installation.
