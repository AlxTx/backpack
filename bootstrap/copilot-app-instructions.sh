#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd -P)
BACKPACK_ROOT=$(CDPATH= cd "$SCRIPT_DIR/.." && pwd -P)
INSTRUCTIONS_PATH=$BACKPACK_ROOT/cockpit/portable/AGENTS.md

if [ ! -f "$INSTRUCTIONS_PATH" ]; then
  printf '✗ missing Backpack instructions: %s\n' "$INSTRUCTIONS_PATH" >&2
  exit 1
fi

case "${1:-}" in
  --copy)
    if ! command -v pbcopy >/dev/null 2>&1; then
      printf '✗ pbcopy is unavailable; run without --copy and paste the output manually.\n' >&2
      exit 1
    fi

    sed '1,4d' "$INSTRUCTIONS_PATH" | pbcopy
    printf '✓ Backpack instructions copied to the clipboard. Paste them in GitHub Copilot App → Settings → General → Global instructions.\n'
    ;;
  '')
    sed '1,4d' "$INSTRUCTIONS_PATH"
    ;;
  *)
    printf 'Usage: %s [--copy]\n' "$0" >&2
    exit 2
    ;;
esac
