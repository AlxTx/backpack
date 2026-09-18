# OpenCode permission badges

Feature spec for an OpenCode TUI/GUI guardrail.

## Problem

OpenCode shows the active model, but the current agent's effective risk level is
not visible enough. In this Backpack workflow, switching agent changes what the
assistant can do:

- `plan` should inspect only and deny shell so auto-approve remains safe;
- `review` and other specialist lenses should inspect only;
- `build` can edit files.

The UI should make that difference visible at a glance.

## Desired status display

Show compact permission badges next to the active agent/model in both TUI and
GUI.

Examples:

```txt
plan        | selected model | READ
build       | selected model | WRITE · SH?
review      | selected model | READ
```

Do not show `READ` when `WRITE` is active; write access already implies the
higher-risk state the user needs to notice.

## Semantic badges

The source of truth should be semantic data, not hardcoded icons:

```ts
type PermissionBadges = {
  access: "no-io" | "read" | "write"
  shell: "deny" | "ask" | "allow"
}
```

Recommended text labels:

| Semantic value | Label | Meaning |
|---|---:|---|
| `access: "no-io"` | `NO-IO` | no meaningful project IO |
| `access: "read"` | `READ` | inspection/read-only |
| `access: "write"` | `WRITE` | can modify files |
| `shell: "ask"` | `SH?` | shell requires confirmation |
| `shell: "allow"` | `SH` | shell is allowed |
| `shell: "deny"` | hidden by default | no shell access |

## Permission reduction

Compute badges from the merged active agent config:

1. If `edit` is effectively `allow`, show `WRITE`.
2. Else if read-like tools are available (`read`, `glob`, `grep`, `list`, or
   equivalent defaults), show `READ`.
3. Else show `NO-IO`.
4. If `bash` is effectively `ask`, append `SH?`.
5. If `bash` is effectively `allow`, append `SH`.
6. If `bash` is effectively `deny`, omit shell badge in compact view.

## Rendering

TUI should prefer stable text labels. Icons can be additive, not required.

Suggested render tiers:

1. GUI chips/badges with color:
   - `NO-IO`: neutral/gray
   - `READ`: blue
   - `WRITE`: orange
   - `SH?`: yellow
   - `SH`: red
2. TUI text fallback:
   - `NO-IO`, `READ`, `WRITE`, `SH?`, `SH`
3. Optional TUI icon mode when supported:
   - lock/read/write/terminal icons, while keeping text or accessible labels.

Avoid relying on emoji as the only representation; emoji and Nerd Font glyphs
vary across OS, terminals, and GUI surfaces.

## Backpack mapping

Expected badges for the current Backpack agents:

| Agent | Expected badge |
|---|---|
| `plan` | `READ` |
| `build` | `WRITE · SH?` |
| `review` | `READ` |
| `product-design` | `READ` |
| `qa` | `READ` |
| `backpack-pattern-scan` | `READ` |

## Current feasibility

As of this note, Backpack cannot implement this cleanly through OpenCode config:

- `tui.json` exposes keybinds such as `status_view`, not status bar composition.
- OpenCode plugins expose behavioral hooks (`config`, `event`, `permission.ask`,
  `tool.execute.*`, `chat.*`) but no TUI/GUI badge hook.
- The plugin type marks TUI extension as unavailable (`tui?: never`).

So this should be implemented upstream in OpenCode core/UI, or through a future
official status badge extension point.

## Upstream issue draft

Title:

```txt
Show active agent permission badges in TUI and GUI status bars
```

Body:

```md
OpenCode currently shows the active model, but not the effective permissions of
the active agent. In workflows with multiple agents/modes, users need a compact
guardrail to know whether the current agent is read-only, can write files, or can
request shell execution.

Proposal: expose semantic permission badges derived from the merged active agent
config and display them in TUI and GUI status bars.

Suggested badges:
- `NO-IO`: no meaningful project IO
- `READ`: inspection/read-only
- `WRITE`: can modify files
- `SH?`: shell requires confirmation
- `SH`: shell allowed

Reduction rules:
- `WRITE` supersedes `READ`; do not show both.
- `bash=ask` adds `SH?`.
- `bash=allow` adds `SH`.
- `bash=deny` is hidden in compact view.

Examples:
- `plan | model | READ`
- `build | model | WRITE · SH?`

The feature should expose semantic data so each surface can render appropriately:
GUI chips, TUI text fallback, optional icons/Nerd Font where supported.
```
