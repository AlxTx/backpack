# Cockpit routing

Mental model:

- `Tab` changes the current primary mode: brainstorm, plan, build, review.
- `/command` runs a prepared action.
- A pinned command uses its declared agent and does not depend on the current mode.
- A subagent is an isolated specialist used for one task.
- Built-in agents are fallback tools, not the main cockpit.

Current cockpit:

```txt
Think   -> brainstorm
Inspect -> plan
Change  -> build
Check   -> review
Learn   -> /pattern-scan, /capture
```
