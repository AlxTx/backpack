#!/usr/bin/env sh
set -eu

CONFIG_DIR=${CONFIG_DIR:-"$HOME/.config"}
BACKPACK_AGENTS_DIR=${BACKPACK_AGENTS_DIR:-"$HOME/.agents"}
BACKPACK_CODEX_DIR=${CODEX_HOME:-"$HOME/.codex"}
BACKPACK_CLAUDE_DIR=${CLAUDE_CONFIG_DIR:-"$HOME/.claude"}
BACKPACK_BIN_DIR=${BACKPACK_BIN_DIR:-"$HOME/.local/bin"}

state() {
  label=$1
  path=$2
  if [ -L "$path" ] && [ ! -e "$path" ]; then
    printf '  ! %-18s broken link\n' "$label"
  elif [ -e "$path" ]; then
    printf '  ✓ %-18s installed\n' "$label"
  else
    printf '  · %-18s not installed\n' "$label"
  fi
}

printf '◆ Backpack status\n\n'
printf 'Cockpit\n'
state 'OpenCode' "$CONFIG_DIR/opencode/AGENTS.md"
state 'Codex' "$BACKPACK_CODEX_DIR/AGENTS.md"
state 'Claude Code' "$BACKPACK_CLAUDE_DIR/rules/backpack.md"
state 'Cockpit skills' "$BACKPACK_AGENTS_DIR/skills/cockpit-prompt-refinement"

printf '\nThis Mac\n'
state 'Shell' "$CONFIG_DIR/fish"
state 'Editor' "$CONFIG_DIR/nvim"
state 'Terminal' "$CONFIG_DIR/ghostty"
state 'Backpack command' "$BACKPACK_BIN_DIR/backpack"

printf '\nProject skills\n'
printf '  Run backpack skills from a project to manage its skills.\n'
