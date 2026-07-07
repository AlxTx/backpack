# Cockpit routing

Mental model:

- `Tab` changes the current primary mode: interactive, plan, autopilot.
- `/command` runs a prepared action.
- A pinned command uses its declared agent and does not depend on the current mode.
- A subagent is an isolated specialist used for one task.
- Built-in agents are fallback tools, not the main cockpit.

Current cockpit:

```txt
Interactive -> clarify, challenge, decide next step
Plan        -> inspect read-only and prepare execution
Autopilot   -> execute scoped changes end-to-end
Review      -> /review existing changes in read-only mode
Learn       -> /pattern-scan, /capture
```

Backpack provides the portable cockpit core. Provider/model choices are edited
locally in `~/.config/opencode/opencode.json` on each machine and stay outside
this repo.

Future guardrail idea: show active agent permission badges in OpenCode UI, e.g.
`NO-IO`, `READ · SH?`, or `WRITE · SH?`. See
[`opencode-permission-badges.md`](opencode-permission-badges.md).
