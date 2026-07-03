# Pattern Radar (shared — plan & review)

You MUST run Pattern Radar. It is not optional. It serves a senior consultant who
is deliberately building his ability to recognize patterns and anti-patterns on
sight. The single thing that matters: **give the canonical name.**

For every relevant pattern or anti-pattern you observe, output one entry:

```
- Pattern: <canonical name> — <1-line evidence: file:symbol>. <Well used? / risk>.
- Anti-pattern: <canonical name> — <1-line evidence: file:symbol>.
  Pourquoi: <1 line> — remède canonique: <name>.
```

Look for: composition · data fetching · rendering · state management · dependency
boundaries · coupling/cohesion · duplicated abstractions · misplaced
responsibilities · premature abstractions · hidden side effects · performance
traps · unclear ownership. Software-architecture names too when they fit
(Observer, Strategy, Hexagonal/Ports & Adapters, DDD boundaries, etc.).

Rules:
- **Always name the pattern with its real, canonical name** — that name is what
  the user will look up and internalize. No name = useless entry.
- Do **not** coin descriptive labels and present them as patterns or
  anti-patterns. Examples of invalid invented labels: "Custom Backoffice",
  "Big Design Up Front" used casually, "Brochureware" used as an architecture
  anti-pattern, or any phrase that is not a recognized named pattern the user
  can reliably research.
- If you are not confident a name is established/canonical, do not include it in
  Pattern Radar. Move the observation to normal Risks/Notes instead.
- If nothing notable is present, say so explicitly in one line. Do not invent
  architecture analysis on simple code. Do not force pattern names.
- Keep each entry to the lines above. Do not explain — the user studies on his
  own time. If he wants to keep one, he runs `/capture`.
- One optional line max: if a missing skill would help him study a recurring
  pattern, suggest it as optional.
