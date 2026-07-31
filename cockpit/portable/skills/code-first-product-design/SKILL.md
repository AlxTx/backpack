---
name: code-first-product-design
description: Turn a business need, vague UI idea, or missing mockup into a concrete content, UX, and UI design handoff without prescribing code.
---

# Code-first Product Design

Use this skill to turn product thinking into concrete content, UX, and UI design
decisions when there is no designer-provided mockup. The output should be a
design handoff that guides future implementation without prescribing code.

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
6. **Design handoff** — exact screens, component intent, responsive behavior,
   acceptance criteria, and design validation checks.

## Brief interrogation

If the request is underspecified, do not invent the whole product. Interview the
user down the design tree until the next decision is clear. Ask only blocking
questions, one decision at a time. If a question can be answered by inspecting
the codebase, inspect instead of asking.

## Design-system defaults

- Prefer existing project components and tokens before proposing new visual
  elements.
- Describe component intent and hierarchy, not component architecture.
- For existing design systems, name the closest primitives/variants to reuse;
  avoid prescribing custom widgets unless the product need requires them.
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
- Keep the handoff concrete enough that a builder can understand the intended
  experience without receiving code instructions.
- Include validation steps: visual check, responsive check, a11y check, behavior
  check.
- Pick a style lens deliberately when no design system exists; justify why it fits
  the product, not because it is trendy.

## Don't

- Do not generate a purely aesthetic moodboard without UX structure.
- Do not invent a brand system if the project already has one.
- Do not recommend Figma-to-code as the default path.
- Do not skip edge states or accessibility because the request sounds visual.
- Do not end with vague polish requests like “make it look professional”; provide
  concrete layout, component intent, and token guidance instead.
