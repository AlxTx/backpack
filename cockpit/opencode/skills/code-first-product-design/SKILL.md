---
name: code-first-product-design
description: Internal design skill for /design and product-design. Do not invoke directly; use /design for business needs, vague UI ideas, or missing mockups.
---

# Code-first Product Design

Use this skill to bridge product thinking and frontend implementation when there
is no designer-provided mockup. The output should be a design contract that can
be implemented directly in code, not decorative inspiration.

## Core principle

Do not start with pixels. Start with the user's job, the decision hierarchy, and
the interface states. Visual style exists to make the product action obvious.

## Required design passes

1. **Product intent** — business goal, target user, main user outcome, success
   signal.
2. **UX flow** — entry point, primary action, completion state, failure paths.
3. **Information architecture** — what must be seen first, second, and only on
   demand.
4. **Interaction states** — loading, empty, error, disabled, success, pending,
   mobile, keyboard/focus.
5. **UI system** — reusable components, layout grid, density, typography,
   spacing, color roles, radius, elevation, iconography, motion.
6. **Build contract** — exact screens/components to implement and validation
   checks.

## Brief interrogation

If the request is underspecified, do not invent the whole product. Interview the
user down the design tree until the next decision is clear. Ask only blocking
questions, one decision at a time. If a question can be answered by inspecting
the codebase, inspect instead of asking.

## Code-first defaults

- Prefer existing project components and tokens before introducing new ones.
- For React apps, prefer composable components over one-off page blobs.
- For shadcn/Radix/Tailwind projects, reuse primitives and variants; avoid raw
  custom widgets unless the product need requires them.
- Treat Storybook, component previews, or app screenshots as the practical source
  of visual truth when Figma is absent.
- Figma is optional: useful for stakeholder validation, not required for code.

## Visual quality gates

- One clear primary action per screen or section.
- Text hierarchy is scannable: title, explanation, action, supporting metadata.
- Spacing is systematic, not hand-tuned per element.
- Empty/error/loading states are designed, not left as afterthoughts.
- Responsive behavior is specified for mobile and desktop.
- Contrast, focus, labels, hit targets, and keyboard navigation meet WCAG 2.2 AA
  expectations when applicable.

## Do

- Propose 2–3 UX options only when the tradeoff is real.
- Name assumptions explicitly.
- Keep the contract concrete enough for a build agent to execute.
- Include validation steps: visual check, responsive check, a11y check, behavior
  check.
- Pick a style lens deliberately when no design system exists; justify why it fits
  the product, not because it is trendy.

## Don't

- Do not generate a purely aesthetic moodboard without UX structure.
- Do not invent a brand system if the project already has one.
- Do not recommend Figma-to-code as the default path.
- Do not skip edge states or accessibility because the request sounds visual.
- Do not ask the build agent to “make it look professional” without concrete
  layout, component, and token guidance.
