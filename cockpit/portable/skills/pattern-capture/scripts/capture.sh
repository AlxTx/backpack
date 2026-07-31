#!/bin/sh
set -eu

# Append a pattern-capture entry to the personal per-project learning log.
# Reads the entry body from stdin and appends; it never overwrites prior entries.

capture_dir="$HOME/dev/ai/pattern-captures"
mkdir -p "$capture_dir"

raw_project=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")
project=$(printf '%s' "$raw_project" | tr ' /' '--')
capture_file="$capture_dir/$project.md"
capture_day=$(date +%Y-%m-%d)

if [ ! -f "$capture_file" ]; then
  printf '# Pattern captures — %s\n' "$raw_project" > "$capture_file"
fi

{
  printf '\n## %s\n\n' "$capture_day"
  cat
  printf '\n'
} >> "$capture_file"

printf '%s\n' "$capture_file"
