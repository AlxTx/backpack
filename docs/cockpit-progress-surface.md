# Cockpit progress surface

Feature spec for making Cockpit activity visible without flooding the
conversation with repetitive status messages.

## Problem

Cockpit currently exposes the active phase and capability through separate
sentences. Repeating the `Cockpit` prefix for the phase and again for a skill
makes short updates feel noisy, while plain prose does not clearly separate
workflow activity from the assistant's response.

The progress surface should feel like a compact terminal status block: easy to
scan, consistent across phases, and secondary to the actual conversation.

## Rendering priority

Use the smallest surface that exposes the event once:

1. **Native host event** — preferred for skills, agents, plugins, integrations,
   tools, and their running state.
2. **Compact fallback line** — only when the host does not expose the activation.
3. **Plain prose** — only when no progress surface exists.

Always announce one non-trivial phase before work starts:

```txt
[Cockpit - <Phase>] · <immediate action>
```

When a host such as Codex desktop then renders `Code Review` and `Product QA` as
native running subagents, emit no additional `[Agent]` lines and do not restate
their obvious roles in prose.

When the host has no native activation event, use the fallback:

```txt
[Cockpit - Validate] · [Agent] Code Review
[Cockpit - Validate] · [Agent] Product QA
```

## Usage rules

- Keep `[Cockpit - <Phase>]` as the stable workflow marker.
- Describe one concrete action or material result in plain language.
- Render a capability name manually only when it is genuinely active and not
  already visible in the host UI.
- Keep capabilities subordinate to the phase; they are operational context, not
  the main message.
- Use the same structure for discussion, design, plan, build, diagnostic,
  validation, review, and learn phases.
- Publish a new block only when the phase changes, a specialized capability
  starts, or a meaningful result is available.
- Avoid step numbers for short work. Add `<current>/<total>` only when the total
  is known and helps the user follow a longer sequence.
- Do not repeat explanatory prose such as why a skill or agent matches the task
  unless that explanation affects scope, permissions, dependencies, or outcome.

## Completion state

A completed phase may use a check mark when the status is unambiguous:

```txt
[Cockpit - Validate] ✓ · aucun défaut bloquant trouvé
```

The check mark reports workflow state only. It does not imply permission to
commit, push, deploy, or perform another external action.

## Portability

The semantic contract remains: phase, current activity or result, and an
optional capability event rendered exactly once by either Cockpit or the host.
