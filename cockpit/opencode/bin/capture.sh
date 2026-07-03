#!/bin/sh
# Append a pattern-capture entry to the PER-PROJECT pattern log.
# Entry body is read from stdin. Target: ~/dev/ai/pattern-captures/<project>.md
# (directory + file created automatically). Appends, never overwrites.
# Project name is auto-detected from the current git repo (else cwd basename).

dir="$HOME/dev/ai/pattern-captures"
mkdir -p "$dir"

rawproject=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")
project=$(printf '%s' "$rawproject" | tr ' /' '--')
file="$dir/$project.md"
day=$(date +%Y-%m-%d)

# Title the file once, on first creation.
if [ ! -f "$file" ]; then
  printf '# Pattern captures — %s\n' "$rawproject" > "$file"
fi

{
  printf '\n## %s\n\n' "$day"
  cat
  printf '\n'
} >> "$file"

echo "$file"
