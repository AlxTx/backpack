# Backpack Engineering progress surface

Feature spec for making Backpack Engineering activity visible without flooding the
conversation with repetitive status messages.

This surface shows current agent activity. The separate project checklist shows
Discovery, Definition, Engineering, and Delivery for the current slice. Its
individual decisions and evidence are described in
[`backpack-routing.md`](backpack-routing.md#start-or-resume-a-project).
The checklist tracks evidenced project progress across conversations; it does
not turn framing milestones into extra agent workflow steps.

## Problem

Backpack Engineering exposes the active step and capability through compact
events. Repeating its name on every line makes short updates feel noisy, while
plain prose does not clearly separate workflow activity from the response.

The progress surface should feel like a compact terminal status block: easy to
scan, consistent across phases, and secondary to the actual conversation.

## Rendering priority

Use the smallest surface that exposes the event once:

1. **Native host event** — preferred for steps, skills, agents, plugins,
   integrations, tools, and their running state when available.
2. **Compact progress line** — when the host has a progress surface but does not
   show the event itself.
3. **Standalone chat status** — when the host has no suitable progress surface.

Explanations use ordinary prose in a separate message or paragraph.

Announce a non-trivial step with a standalone status before work starts:

```txt
💭 Explore - Inspecter le parcours
```

The status is only a short activity label. It never begins a sentence explaining
the work or repeats the answer. Put material findings and next decisions in a
separate paragraph without the marker. If the host already shows the step, do
not echo it in chat.

When a host such as Codex desktop then renders `Code Review` and `Product QA` as
native running subagents, emit no additional `[Agent]` lines and do not restate
their obvious roles in prose.

When the host has no native activation event, use the fallback:

```txt
⚖️ Validate - [Agent] Code Review
⚖️ Validate - [Agent] Product QA
```

## Usage rules

- Use `💭 Explore`, `📋 Plan`, `🛠️ Build`, `⚖️ Validate`, and `📚 Learn` as the
  five visible workflow steps. `🧭 Kickoff` is a guided entry into Explore or
  Plan, not a sixth mandatory step.
- Keep step names and Backpack command names in English and Title Case, even
  when the conversation uses another language. If emoji rendering is unreliable,
  keep the English name without the emoji.
- Keep Diagnose and Pattern scan within Explore, Team build within Build, and
  Code Review and Product QA within Validate. Their distinct behavior and
  permissions still apply; they do not need extra top-level steps.
- Keep the status to a few words; explain any material result separately.
- Render a capability name manually only when it is genuinely active and not
  already visible in the host UI.
- Keep capabilities subordinate to the phase; they are operational context, not
  the main message.
- Use the same structure for discussion, design, planning, building, diagnosis,
  validation, review, and learning.
- Publish a new status only when the phase changes or a specialized capability
  starts or finishes. Use normal prose for meaningful results.
- Avoid step numbers for short work. Add `<current>/<total>` only when the total
  is known and helps the user follow a longer sequence.
- Do not repeat explanatory prose such as why a skill or agent matches the task
  unless that explanation affects scope, permissions, dependencies, or outcome.

## Completion state

A completed phase may use a check mark when the status is unambiguous:

```txt
⚖️ Validate ✓
```

Explain the verdict separately. The check mark reports workflow state only. It
does not imply permission to commit, push, deploy, or perform another external
action.

## Portability

The semantic contract remains: phase, current activity or result, and an
optional capability event rendered exactly once by either Backpack Engineering or the host.
