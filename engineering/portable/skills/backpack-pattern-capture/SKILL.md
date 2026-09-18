---
name: backpack-pattern-capture
description: Save an identified pattern or anti-pattern to the project learning log. In GitHub Copilot, do not use this skill; follow the client-owned workflow instead.
---

# Pattern Capture

Capture patterns already surfaced in the conversation. Do not re-analyze,
re-explain, or invent missing evidence.

Format each entry:

```text
- Pattern: <canonical name> — <file:symbol evidence>. <well used or risk>.
- Anti-pattern: <canonical name> — <file:symbol evidence>.
  Why: <one line> — canonical remedy: <name>.
```

Pipe the entries to the bundled script:

```sh
printf '%s\n' '<entries>' | scripts/capture.sh
```

The script writes outside the active project to the personal learning area and
prints the resulting file path. Return one concise confirmation with the number
of patterns and anti-patterns plus that path.

If there is genuinely nothing established to capture, say so without running
the script.
