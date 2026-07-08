---
name: frontend-design
description: Internal visual skill for /design and build. Do not invoke directly; use only after a distinctive visual direction is explicitly requested or selected.
---

# Frontend Design

Source: Anthropic `frontend-design` skill, captured from AI UX Playground on
2026-07-08.

This skill guides creation of distinctive, production-grade frontend interfaces
that avoid generic "AI slop" aesthetics. Use it as a visual execution lens when
the user or product-design contract selected a clear aesthetic direction.

In read-only product-design work, do not implement. Extract concrete visual rules
for the implementation contract instead. In build work, implement real working
code with exceptional attention to aesthetic details and creative choices.

Do not use this skill for routine component/page work, bugfixes, refactors, or
existing design-system implementation unless the request explicitly asks for a
new or stronger visual direction.

## Design Thinking

Before coding, understand the context and commit to a BOLD aesthetic direction:

- **Purpose**: What problem does this interface solve? Who uses it?
- **Tone**: Pick an extreme: brutally minimal, maximalist chaos,
  retro-futuristic, organic/natural, luxury/refined, playful/toy-like,
  editorial/magazine, brutalist/raw, art deco/geometric, soft/pastel,
  industrial/utilitarian, etc.
- **Constraints**: Technical requirements (framework, performance,
  accessibility).
- **Differentiation**: What makes this unforgettable? What's the one thing
  someone will remember?

**Critical**: Choose a clear conceptual direction and execute it with precision.
Bold maximalism and refined minimalism both work — the key is intentionality,
not intensity.

## Frontend Aesthetics Guidelines

Focus on:

- **Typography**: Choose fonts that are beautiful, unique, and interesting. Avoid
  generic fonts like Arial and Inter when a stronger project fit exists.
- **Color & Theme**: Commit to a cohesive aesthetic. Use CSS variables for
  consistency. Dominant colors with sharp accents outperform timid,
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

**Important**: Match implementation complexity to the aesthetic vision.
Maximalist designs need elaborate code with extensive animations and effects.
Minimalist or refined designs need restraint, precision, and careful attention
to spacing, typography, and subtle details.
