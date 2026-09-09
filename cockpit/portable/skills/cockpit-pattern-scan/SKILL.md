---
name: cockpit-pattern-scan
description: In GitHub Copilot, use only when the user explicitly invokes /cockpit-pattern-scan; never select automatically. Map established architecture, JavaScript, and framework patterns or anti-patterns in an unfamiliar codebase. In other hosts, use for onboarding and explicit pattern scans; not for implementation plans or diff review.
---

# Pattern Scan

Inspect the requested scope in strict read-only mode. The goal is a concise map
of patterns that helps a senior consultant understand an unfamiliar codebase
before changing it.

Cover only the layers supported by evidence:

1. **Architecture** — boundaries, layering, dependency direction, ownership,
   coupling/cohesion, ports and adapters, domain boundaries.
2. **JavaScript / language** — idioms, async flows, data structures, state,
   side effects, runtime or performance traps.
3. **Framework** — composition, data fetching, rendering, hydration, state
   placement, design-system conventions.

For each useful observation:

```text
- Pattern: <canonical name> — <file:symbol evidence>. <well used or risk>.
- Anti-pattern: <canonical name> — <file:symbol evidence>.
  Why: <one line> — canonical remedy: <name>.
```

Rules:

- Use established, searchable names only.
- Do not coin labels or force architecture onto simple code.
- If a layer has nothing notable, say so.
- Do not modify files or turn the scan into an implementation plan.

Return:

```text
Scope: [...]
Stack detected: [...]

Architecture:
- [...]

JavaScript:
- [...]

Framework:
- [...]

Top 3 things to know before touching this code:
1. [...]
2. [...]
3. [...]
```
