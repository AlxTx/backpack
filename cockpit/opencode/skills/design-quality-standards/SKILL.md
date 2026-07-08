---
name: design-quality-standards
description: Internal design quality skill for /design and review. Do not invoke directly; use /design for UX/UI hierarchy, layout, accessibility, and polish.
---

# Design Quality Standards

Use this skill as the non-negotiable quality bar for product UI. It is not a
style direction. It is the standard that every direction must satisfy.

## UX foundations

- State the primary user job and the primary action before discussing visuals.
- Make hierarchy obvious: what to read first, what to do next, what can wait.
- Prefer progressive disclosure over showing every control at once.
- Design the boring states: empty, loading, error, disabled, pending, success,
  permission denied, no results, slow network.
- Minimize mode errors: labels, affordances, confirmation, undo, clear escape
  paths.

## Visual foundations

- Use a deliberate spacing scale. Avoid one-off margins that only work locally.
- Typography must create rhythm: display, title, body, caption, metadata.
- Color roles must be semantic: background, surface, border, text, muted,
  primary, destructive, warning, success, focus.
- Density must match context: calm for decision-making, compact for expert/data
  workflows, spacious for marketing or onboarding.
- Every decorative element must reinforce the product tone or hierarchy.

## Accessibility and interaction

- Meet WCAG 2.2 AA expectations for contrast, focus visibility, labels, target
  size, and keyboard navigation where applicable.
- Preserve semantic HTML and accessible component primitives.
- Specify responsive behavior, not only desktop layout.
- Motion must respect clarity and should be disable-friendly.

## Anti-slop checks

- No default AI SaaS look: generic cards, purple gradients, Lucide icons
  everywhere, centered hero copy, and random glass effects.
- No equal-weight UI where everything competes for attention.
- No visual novelty that makes the primary action less obvious.
- No style pack if the existing product already has a design system.

## Output expectation

When used in product design, include a short quality rationale:

```txt
Design quality rationale:
- Hierarchy: ...
- Interaction states: ...
- Accessibility: ...
- Visual distinctiveness: ...
```
