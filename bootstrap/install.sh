#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd -P)
DEFAULT_BACKPACK_ROOT=$(CDPATH= cd "$SCRIPT_DIR/.." && pwd -P)
BACKPACK_ROOT=${BACKPACK_ROOT:-"$DEFAULT_BACKPACK_ROOT"}
if [ ! -d "$BACKPACK_ROOT" ]; then
  printf 'i ignoring stale BACKPACK_ROOT: %s\n' "$BACKPACK_ROOT"
  BACKPACK_ROOT=$DEFAULT_BACKPACK_ROOT
fi
CONFIG_DIR=${CONFIG_DIR:-"$HOME/.config"}
APPLY=0
DIRECT_APPLY=0
PROFILE_MODE=personal

while [ "${1:-}" != "" ]; do
  case "$1" in
    --apply)
      APPLY=1
      DIRECT_APPLY=1
      ;;
    --personal)
      PROFILE_MODE=personal
      ;;
    --client)
      PROFILE_MODE=client
      ;;
    *)
      printf 'Usage: %s [--personal|--client] [--apply]\n' "$0" >&2
      exit 2
      ;;
  esac
  shift
done

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

ensure_profile_dir() {
  if [ "$APPLY" -eq 0 ]; then
    printf 'would ensure local profile dir: %s\n' "$CONFIG_DIR/opencode-profiles"
  else
    mkdir -p "$CONFIG_DIR/opencode-profiles"
    printf '✓ local profile dir exists: %s\n' "$CONFIG_DIR/opencode-profiles"
  fi
}

print_client_reminder() {
  if [ "$PROFILE_MODE" = "client" ]; then
    cat <<EOF

Client mode reminder:
- Backpack installs only the portable opencode core.
- Create the real client profile locally in $CONFIG_DIR/opencode-profiles/.
- Do not commit client providers, tokens, endpoints, or policies to Backpack.
EOF
  fi
}

run_doctor() {
  BACKPACK_ROOT=$BACKPACK_ROOT "$SCRIPT_DIR/doctor.sh"
}

run_plan() {
  cat <<EOF
Backpack install

Backpack root: $BACKPACK_ROOT
Config dir:     $CONFIG_DIR
Profile mode:   $PROFILE_MODE
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
  ensure_profile_dir
  print_client_reminder
}

if [ "$DIRECT_APPLY" -eq 1 ]; then
  printf 'Step 1/2: checking backpack\n\n'
else
  printf 'Step 1/3: checking backpack\n\n'
fi
run_doctor

if [ "$DIRECT_APPLY" -eq 1 ]; then
  printf '\nStep 2/2: applying config wiring\n\n'
  run_plan
  printf '\n✓ install complete\n'
  if [ -d "$backup_dir" ]; then
    printf 'Backups: %s\n' "$backup_dir"
  fi
  exit 0
fi

printf '\nStep 2/3: previewing config wiring\n\n'
APPLY=0
run_plan

cat <<EOF

No changes were made yet.
EOF
printf 'Apply this plan now? [y/N] '
read answer

case $answer in
  y|Y|yes|YES)
    APPLY=1
    printf '\nStep 3/3: applying config wiring\n\n'
    run_plan
    ;;
  *)
    printf '\nInstall cancelled. No changes were made.\n'
    exit 0
    ;;
esac

printf '\n✓ install complete\n'
if [ -d "$backup_dir" ]; then
  printf 'Backups: %s\n' "$backup_dir"
fi
