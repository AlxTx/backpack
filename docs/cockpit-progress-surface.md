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

## Canonical format

Use a connected three-line block when a skill is active:

```txt
┌─ Cockpit › <Phase>
│  <Immediate action or material result>
└─ Skill: <canonical-skill-name>
```

Example:

```txt
┌─ Cockpit › Plan
│  J'inspecte l'existant et prépare les changements.
└─ Skill: pattern-scan
```

When no skill is active, close the block with the activity itself:

```txt
┌─ Cockpit › Diagnostic
└─ Je vérifie les logs et l'état local d'OpenCode.
```

## Usage rules

- Keep `Cockpit › <Phase>` as the stable workflow marker.
- Describe one concrete action or material result in plain language.
- Render `Skill: <name>` only when a skill is genuinely active.
- Keep the skill subordinate to the phase and activity; it is operational
  context, not the main message.
- Use the same structure for discussion, design, plan, build, diagnostic,
  validation, review, and learn phases.
- Publish a new block only when the phase changes, a specialized capability
  starts, or a meaningful result is available.
- Avoid step numbers for short work. Add `<current>/<total>` only when the total
  is known and helps the user follow a longer sequence.
- Do not repeat explanatory prose such as why a skill matches the task unless
  that explanation affects scope, permissions, or the outcome.

## Completion state

A completed phase may use a check mark when the status is unambiguous:

```txt
┌─ Cockpit › Validate ✓
└─ Les contrôles ciblés passent; aucun défaut bloquant trouvé.
```

The check mark reports workflow state only. It does not imply permission to
commit, push, deploy, or perform another external action.

## Portability

The characters are presentation, not semantics. A host that cannot render the
box-drawing form may fall back to:

```txt
Cockpit › Plan · J'inspecte l'existant et prépare les changements.
Skill: pattern-scan
```

The semantic contract remains: phase, current activity or result, and optional
active skill.
