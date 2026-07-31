# Cockpit routing

Mental model:

- `Tab` changes the current primary mode: interactive, design, plan,
  build.
- `/command` runs a prepared action.
- A pinned command uses its declared agent and does not depend on the current mode.
- A subagent is an isolated specialist used for one task.
- Built-in agents are fallback tools, not the main cockpit.

Current cockpit:

```txt
Interactive -> clarify, challenge, decide next step
Design      -> frame content, journeys, UX/UI, or no-mockup ideas
Plan        -> inspect read-only and prepare execution
Build       -> execute scoped changes end-to-end
Review      -> /review existing changes in read-only mode
Learn       -> /pattern-scan, /capture
```

Backpack provides the portable cockpit core. The updater preserves provider/model
choices edited locally in `~/.config/opencode/opencode.json` on each machine.
The current GPT-5.6 routing is documented in `cockpit/portable/MODELS.md`: Terra
for balanced work, Sol for uncertainty and high-risk review, Luna for settled
implementation and routine execution.

Future guardrail idea: show active agent permission badges in OpenCode UI, e.g.
`NO-IO`, `READ · SH?`, or `WRITE · SH?`. See
[`opencode-permission-badges.md`](opencode-permission-badges.md).
