---
name: frontend-design
description: Define a distinctive production-grade frontend visual direction. Use when the user explicitly requests stronger visual character or selects an aesthetic direction.
---

# Frontend Design

Source: Anthropic `frontend-design` skill, captured from AI UX Playground on
2026-07-08.

This skill guides definition of distinctive, production-grade frontend interface
directions that avoid generic "AI slop" aesthetics. Use it as a visual design
lens when the user or product-design work selected a clear aesthetic
direction.

In read-only product-design work, do not implement. Extract concrete visual rules
for the design handoff instead: hierarchy, composition, typography, color roles,
motion intent, texture, density, and constraints.

Do not use this skill for routine component/page work, bugfixes, refactors, or
existing design-system work unless the request explicitly asks for a new or
stronger visual direction.

## Design Thinking

Before defining the visual direction, understand the context and commit to a BOLD
aesthetic direction:

- **Purpose**: What problem does this interface solve? Who uses it?
- **Tone**: Pick an extreme: brutally minimal, maximalist chaos,
  retro-futuristic, organic/natural, luxury/refined, playful/toy-like,
  editorial/magazine, brutalist/raw, art deco/geometric, soft/pastel,
  industrial/utilitarian, etc.
- **Constraints**: Product, brand, accessibility, responsiveness, delivery risk,
  and existing design-system constraints.
- **Differentiation**: What makes this unforgettable? What's the one thing
  someone will remember?

**Critical**: Choose a clear conceptual direction and execute it with precision.
Bold maximalism and refined minimalism both work — the key is intentionality,
not intensity.

## Frontend Aesthetics Guidelines

Focus on:

- **Typography**: Choose fonts that are beautiful, unique, and interesting. Avoid
  generic fonts like Arial and Inter when a stronger project fit exists.
- **Color & Theme**: Commit to a cohesive aesthetic. Specify semantic color/token
  intent for consistency. Dominant colors with sharp accents outperform timid,
  evenly-distributed palettes.
- **Motion**: Use animations for effects and micro-interactions. Focus on
  high-impact moments: one well-orchestrated page load with staggered reveals
  creates more delight than scattered micro-interactions.
- **Spatial Composition**: Unexpected layouts. Asymmetry. Overlap. Diagonal
  flow. Grid-breaking elements. Generous negative space or controlled density.
- **Backgrounds & Visual Details**: Create atmosphere and depth rather than
  defaulting to solid colors. Add contextual effects and textures that match the
  overall aesthetic.

Never use generic AI-generated aesthetics like overused font families, clichéd
color schemes (especially purple gradients on white backgrounds), predictable
layouts, and default component patterns.

Interpret creatively and make unexpected choices that feel genuinely designed
for the context. No two designs should feel the same.

**Important**: Match visual complexity and delivery risk to the aesthetic vision.
Maximalist designs need stronger motion/detail specifications. Minimalist or
refined designs need restraint, precision, and careful attention to spacing,
typography, and subtle details.
