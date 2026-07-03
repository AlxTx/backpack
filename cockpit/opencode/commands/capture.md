---
description: Capture the pattern(s) just discussed into the personal pattern log, without polluting the conversation.
---

**You ARE allowed to run `~/.config/opencode/bin/capture.sh` here — in ANY agent,
including plan and review read-only modes.** The script appends to a personal
learning log OUTSIDE the project; it is NOT a project modification, NOT "running a
command" in the read-only sense, and NOT blocked by plan mode. Do NOT refuse with
"read-only", "plan mode", or "cannot run commands" — just run it.

Take the pattern(s) and anti-pattern(s) already surfaced in the current
conversation (typically the latest Pattern Radar). Do NOT re-analyze, do NOT
re-explain, do NOT ask questions.

Format each as one bullet, canonical name first:

```
- Pattern: <name> — <evidence file:symbol>. <well used / risk>.
- Anti-pattern: <name> — <evidence file:symbol>. Pourquoi: <1 line> — remède: <name>.
```

Then append them by piping that block to the capture script (this auto-detects
project, date, and target file):

```
printf '%s\n' '<the bullets above>' | ~/.config/opencode/bin/capture.sh
```

If $ARGUMENTS is non-empty, capture that text instead of the conversation patterns.

Reply with exactly one line: `✓ capturé (<n> pattern, <m> anti-pattern) → <file path returned by the script>`. Nothing else.
