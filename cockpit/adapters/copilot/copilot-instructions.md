---
applyTo: "**"
---

# FSH engineering workflow

For Chanel work, `fsh-ghcopilot-plugin` defines the default delivery workflow.
Use the repository instructions and existing project conventions as the
technical source of truth.

Cockpit capabilities are optional personal utilities. Never activate a
`cockpit-*` skill automatically. Use one only when the user explicitly invokes
its `/cockpit-*` name, keep its scope limited to that request, then return
control to the FSH workflow.
