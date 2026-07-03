#!/usr/bin/env sh
set -eu

BACKPACK_ROOT=${BACKPACK_ROOT:-"$HOME/perso/backpack"}
CONFIG_DIR=${CONFIG_DIR:-"$HOME/.config"}
APPLY=0

if [ "${1:-}" = "--apply" ]; then
  APPLY=1
elif [ "${1:-}" != "" ]; then
  printf 'Usage: %s [--apply]\n' "$0" >&2
  exit 2
fi

backup_dir="$HOME/.config.backup.$(date +%Y%m%d-%H%M%S)"

link_entry() {
  source_path=$1
  target_path=$2

  if [ ! -e "$source_path" ]; then
    printf '✗ missing source: %s\n' "$source_path" >&2
    exit 1
  fi

  if [ "$APPLY" -eq 0 ]; then
    printf 'would link: %s -> %s\n' "$target_path" "$source_path"
    return
  fi

  mkdir -p "$(dirname "$target_path")"

  if [ -L "$target_path" ]; then
    current=$(readlink "$target_path")
    if [ "$current" = "$source_path" ]; then
      printf '✓ already linked: %s\n' "$target_path"
      return
    fi
  fi

  if [ -e "$target_path" ] || [ -L "$target_path" ]; then
    mkdir -p "$backup_dir"
    backup_path="$backup_dir/$(basename "$target_path")"
    mv "$target_path" "$backup_path"
    printf 'backup: %s -> %s\n' "$target_path" "$backup_path"
  fi

  ln -s "$source_path" "$target_path"
  printf 'linked: %s -> %s\n' "$target_path" "$source_path"
}

cat <<EOF
Backpack install

Backpack root: $BACKPACK_ROOT
Config dir:     $CONFIG_DIR
Mode:           $(if [ "$APPLY" -eq 1 ]; then printf 'apply'; else printf 'dry-run'; fi)

EOF

link_entry "$BACKPACK_ROOT/cockpit/opencode" "$CONFIG_DIR/opencode"
link_entry "$BACKPACK_ROOT/dotfiles/fish" "$CONFIG_DIR/fish"
link_entry "$BACKPACK_ROOT/dotfiles/nvim" "$CONFIG_DIR/nvim"
link_entry "$BACKPACK_ROOT/dotfiles/karabiner" "$CONFIG_DIR/karabiner"
link_entry "$BACKPACK_ROOT/dotfiles/ghostty" "$CONFIG_DIR/ghostty"
link_entry "$BACKPACK_ROOT/dotfiles/starship/starship.toml" "$CONFIG_DIR/starship.toml"
link_entry "$BACKPACK_ROOT/dotfiles/starship/starship-catppuccin.toml" "$CONFIG_DIR/starship-catppuccin.toml"
link_entry "$BACKPACK_ROOT/dotfiles/starship/starship-dragon.toml" "$CONFIG_DIR/starship-dragon.toml"
link_entry "$BACKPACK_ROOT/dotfiles/starship/starship-tokyo.toml" "$CONFIG_DIR/starship-tokyo.toml"

if [ "$APPLY" -eq 0 ]; then
  cat <<EOF

Dry-run only. No changes were made.
Run with --apply to backup existing entries and create symlinks.
EOF
else
  printf '\n✓ install complete\n'
  if [ -d "$backup_dir" ]; then
    printf 'Backups: %s\n' "$backup_dir"
  fi
fi
