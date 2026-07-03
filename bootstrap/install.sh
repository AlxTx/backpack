#!/usr/bin/env sh
set -eu

BACKPACK_ROOT=${BACKPACK_ROOT:-"$HOME/perso/backpack"}

cat <<EOF
Backpack install is intentionally non-destructive in phase 1.

Backpack root: $BACKPACK_ROOT

Future symlinks:
  ~/.config/opencode       -> $BACKPACK_ROOT/cockpit/opencode
  ~/.config/fish           -> $BACKPACK_ROOT/dotfiles/fish
  ~/.config/nvim           -> $BACKPACK_ROOT/dotfiles/nvim
  ~/.config/karabiner      -> $BACKPACK_ROOT/dotfiles/karabiner
  ~/.config/ghostty        -> $BACKPACK_ROOT/dotfiles/ghostty
  ~/.config/starship.toml  -> $BACKPACK_ROOT/dotfiles/starship/starship.toml

No changes were made.
EOF
