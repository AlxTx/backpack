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
INSTALL_TARGET=all
TARGET_SET=0
REPLACE_EXISTING=0
UPDATE_EXISTING=0

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
    --only)
      shift
      case "${1:-}" in
        opencode|shell|editor|terminal|all)
          INSTALL_TARGET=$1
          TARGET_SET=1
          ;;
        *)
          printf 'Usage: %s [--personal|--client] [--only opencode|shell|editor|terminal|all] [--replace] [--update] [--apply]\n' "$0" >&2
          exit 2
          ;;
      esac
      ;;
    --replace)
      REPLACE_EXISTING=1
      ;;
    --update)
      UPDATE_EXISTING=1
      ;;
    *)
      printf 'Usage: %s [--personal|--client] [--only opencode|shell|editor|terminal|all] [--replace] [--update] [--apply]\n' "$0" >&2
      exit 2
      ;;
  esac
  shift
done

backup_dir="$HOME/.config.backup.$(date +%Y%m%d-%H%M%S)"

if [ -t 1 ]; then
  ESC=$(printf '\033')
  BOLD="${ESC}[1m"
  DIM="${ESC}[2m"
  RESET="${ESC}[0m"
  GREEN="${ESC}[32m"
  CYAN="${ESC}[36m"
  YELLOW="${ESC}[33m"
else
  BOLD=
  DIM=
  RESET=
  GREEN=
  CYAN=
  YELLOW=
fi

title() {
  printf '%s◆ Backpack%s\n' "$BOLD$CYAN" "$RESET"
}

section() {
  printf '\n%s%s%s\n' "$BOLD" "$1" "$RESET"
}

muted() {
  printf '%s%s%s\n' "$DIM" "$1" "$RESET"
}

success() {
  printf '%s✓%s %s\n' "$GREEN" "$RESET" "$1"
}

info() {
  printf '%s›%s %s\n' "$CYAN" "$RESET" "$1"
}

warn() {
  printf '%s!%s %s\n' "$YELLOW" "$RESET" "$1"
}

choice_prompt() {
  printf '\n%s?%s %s' "$CYAN" "$RESET" "$1"
}

use_gum() {
  [ -t 0 ] && [ -t 1 ] && command -v gum >/dev/null 2>&1
}

offer_gum_install() {
  if [ ! -t 0 ] || [ ! -t 1 ]; then
    return 0
  fi
  command -v gum >/dev/null 2>&1 && return

  if ! command -v brew >/dev/null 2>&1; then
    warn 'Optional: install gum later for a better setup UI: brew install gum'
    return
  fi

  title
  cat <<EOF
Gum is not installed.

Backpack can use Gum for a modern selectable setup UI.
Without it, the installer still works with a simple numbered menu.
EOF

  choice_prompt 'Install gum now with Homebrew? [y/N] '
  read answer

  case $answer in
    y|Y|yes|YES)
      if brew install gum; then
        success 'Gum installed'
      else
        warn 'Could not install gum; continuing with the simple menu.'
      fi
      ;;
    *)
      info 'Continuing with the simple menu'
      ;;
  esac

  printf '\n'
}

gum_header() {
  gum style \
    --foreground 39 \
    --border-foreground 39 \
    --border rounded \
    --padding '1 2' \
    --margin '1 0' \
    '◆ Backpack' 'Portable setup for a fresh machine.'
}

gum_choose_target() {
  gum_header

  selection=$(gum choose \
    --header 'What do you want to unpack?' \
    --cursor '→ ' \
    --selected-prefix '✓ ' \
    --unselected-prefix '  ' \
    'OpenCode     Agents, prompts, commands → ~/.config/opencode' \
    'Shell        Fish + Starship' \
    'Editor       Neovim' \
    'Terminal UI  Ghostty + Karabiner' \
    'Everything   All Backpack config' \
    'Quit') || {
      warn 'Install cancelled. No changes were made.'
      exit 0
    }

  case $selection in
    OpenCode*) INSTALL_TARGET=opencode ;;
    Shell*) INSTALL_TARGET=shell ;;
    Editor*) INSTALL_TARGET=editor ;;
    Terminal*) INSTALL_TARGET=terminal ;;
    Everything*) INSTALL_TARGET=all ;;
    Quit)
      warn 'Install cancelled. No changes were made.'
      exit 0
      ;;
  esac
}

gum_choose_existing_opencode() {
  target_path=$1

  gum style \
    --foreground 214 \
    --border-foreground 214 \
    --border rounded \
    --padding '1 2' \
    --margin '1 0' \
    'OpenCode config already exists' "$target_path"

  selection=$(gum choose \
    --header 'What do you want to do?' \
    --cursor '→ ' \
    --selected-prefix '✓ ' \
    --unselected-prefix '  ' \
    'Keep existing config' \
    'Backup existing and install fresh from Backpack' \
    'Cancel') || {
      warn 'Install cancelled. No changes were made.'
      exit 0
    }

  case $selection in
    Keep*)
      success "kept existing $target_path"
      return 1
      ;;
    Backup*)
      return 0
      ;;
    Cancel)
      warn 'Install cancelled. No changes were made.'
      exit 0
      ;;
  esac
}

confirm_apply() {
  if use_gum; then
    gum confirm 'Apply this plan now?' && return 0
    return 1
  fi

  choice_prompt 'Apply this plan now? [y/N] '
  read answer
  case $answer in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

ask_install_target() {
  if use_gum; then
    gum_choose_target
    return
  fi

  cat <<EOF
$(title)
Portable setup for a fresh machine.

What do you want to unpack?

  1  OpenCode     Agents, prompts, commands → ~/.config/opencode
  2  Shell        Fish + Starship
  3  Editor       Neovim
  4  Terminal UI  Ghostty + Karabiner
  5  Everything   All Backpack config
  q  Quit

EOF

  choice_prompt 'Select an option: '
  read choice

  case $choice in
    1) INSTALL_TARGET=opencode ;;
    2) INSTALL_TARGET=shell ;;
    3) INSTALL_TARGET=editor ;;
    4) INSTALL_TARGET=terminal ;;
    5) INSTALL_TARGET=all ;;
    q|Q)
      printf '\n'
      warn 'Install cancelled. No changes were made.'
      exit 0
      ;;
    *)
      printf '✗ invalid choice: %s\n' "$choice" >&2
      exit 2
      ;;
  esac
}

backup_existing() {
  target_path=$1

  mkdir -p "$backup_dir"
  backup_path="$backup_dir/$(basename "$target_path")"
  mv "$target_path" "$backup_path"
  LAST_BACKUP_PATH=$backup_path
  info "backup $target_path -> $backup_path"
}

copy_dir() {
  source_path=$1
  target_path=$2

  mkdir -p "$(dirname "$target_path")"
  cp -R "$source_path" "$target_path"
  success "copied $target_path"
}

copy_path_replace() {
  source_path=$1
  target_path=$2

  rm -rf "$target_path"
  mkdir -p "$(dirname "$target_path")"
  cp -R "$source_path" "$target_path"
  success "updated $target_path"
}

update_opencode_core() {
  source_root=$1
  target_root=$2

  if [ ! -d "$source_root" ]; then
    printf '✗ missing source dir: %s\n' "$source_root" >&2
    exit 1
  fi

  if [ ! -d "$target_root" ]; then
    if [ "$APPLY" -eq 0 ]; then
      info "copy $source_root -> $target_root"
      return
    fi

    copy_dir "$source_root" "$target_root"
    return
  fi

  if [ "$APPLY" -eq 0 ]; then
    info "backup $target_root"
    info "update OpenCode core files without touching $target_root/opencode.json"
    return
  fi

  backup_existing "$target_root"
  mkdir -p "$target_root"

  if [ -f "$LAST_BACKUP_PATH/opencode.json" ]; then
    cp "$LAST_BACKUP_PATH/opencode.json" "$target_root/opencode.json"
    success "kept $target_root/opencode.json"
  fi

  for entry in prompts commands themes bin templates README.md tui.json .gitignore; do
    if [ -e "$source_root/$entry" ]; then
      copy_path_replace "$source_root/$entry" "$target_root/$entry"
    fi
  done

  cat <<EOF

Kept local config:
  $target_root/opencode.json

If Backpack agents or permissions changed, manually merge:
  from: $source_root/opencode.json
  to:   $target_root/opencode.json
EOF
}

ask_replace_existing_dir() {
  target_path=$1

  if use_gum; then
    gum_choose_existing_opencode "$target_path"
    return $?
  fi

  cat <<EOF

$(section 'Existing OpenCode config')
$target_path

What do you want to do?

  1  Keep existing config
  2  Backup existing and install fresh from Backpack
  q  Cancel

EOF

  choice_prompt 'Select an option: '
  read choice

  case $choice in
    1)
      success "kept existing $target_path"
      return 1
      ;;
    2)
      return 0
      ;;
    q|Q)
      printf '\n'
      warn 'Install cancelled. No changes were made.'
      exit 0
      ;;
    *)
      printf '✗ invalid choice: %s\n' "$choice" >&2
      exit 2
      ;;
  esac
}

link_entry() {
  source_path=$1
  target_path=$2

  if [ ! -e "$source_path" ]; then
    printf '✗ missing source: %s\n' "$source_path" >&2
    exit 1
  fi

  if [ "$APPLY" -eq 0 ]; then
    info "link $target_path -> $source_path"
    return
  fi

  mkdir -p "$(dirname "$target_path")"

  if [ -L "$target_path" ]; then
    current=$(readlink "$target_path")
    if [ "$current" = "$source_path" ]; then
      success "already linked $target_path"
      return
    fi
  fi

  if [ -e "$target_path" ] || [ -L "$target_path" ]; then
    mkdir -p "$backup_dir"
    backup_existing "$target_path"
  fi

  ln -s "$source_path" "$target_path"
  success "linked $target_path"
}

copy_dir_once() {
  source_path=$1
  target_path=$2

  if [ ! -d "$source_path" ]; then
    printf '✗ missing source dir: %s\n' "$source_path" >&2
    exit 1
  fi

  if [ -e "$target_path" ] || [ -L "$target_path" ]; then
    if [ "$APPLY" -eq 0 ]; then
      if [ "$REPLACE_EXISTING" -eq 1 ]; then
        info "replace existing $target_path"
      else
        info "ask keep or replace $target_path"
      fi
      return
    fi

    if [ "$REPLACE_EXISTING" -eq 0 ]; then
      if [ "$DIRECT_APPLY" -eq 1 ]; then
        success "kept existing $target_path"
        return
      fi

      if ! ask_replace_existing_dir "$target_path"; then
        return
      fi
    fi

    backup_existing "$target_path"
    copy_dir "$source_path" "$target_path"
    return
  fi

  if [ "$APPLY" -eq 0 ]; then
    info "copy $source_path -> $target_path"
    return
  fi

  copy_dir "$source_path" "$target_path"
}

print_client_reminder() {
  if [ "$PROFILE_MODE" = "client" ]; then
    cat <<EOF

Client mode reminder:
- Backpack copies the portable opencode core once to $CONFIG_DIR/opencode.
- Edit $CONFIG_DIR/opencode/opencode.json locally for client LLM providers/models.
- Do not commit client providers, tokens, endpoints, or policies to Backpack.
EOF
  fi
}

run_doctor() {
  BACKPACK_DOCTOR_QUIET=1 BACKPACK_ROOT=$BACKPACK_ROOT "$SCRIPT_DIR/doctor.sh"
  success 'Backpack health check passed'
}

run_plan() {
  cat <<EOF
$(section 'Install plan')

  Backpack  $BACKPACK_ROOT
  Config    $CONFIG_DIR
  Target    $INSTALL_TARGET
  Mode      $(if [ "$APPLY" -eq 1 ]; then printf 'apply'; else printf 'preview'; fi)

EOF

  case "$INSTALL_TARGET" in
    opencode|all)
      if [ "$UPDATE_EXISTING" -eq 1 ]; then
        update_opencode_core "$BACKPACK_ROOT/cockpit/opencode" "$CONFIG_DIR/opencode"
      else
        copy_dir_once "$BACKPACK_ROOT/cockpit/opencode" "$CONFIG_DIR/opencode"
      fi
      ;;
  esac

  case "$INSTALL_TARGET" in
    shell|all)
      link_entry "$BACKPACK_ROOT/dotfiles/fish" "$CONFIG_DIR/fish"
      link_entry "$BACKPACK_ROOT/dotfiles/starship/starship.toml" "$CONFIG_DIR/starship.toml"
      link_entry "$BACKPACK_ROOT/dotfiles/starship/starship-catppuccin.toml" "$CONFIG_DIR/starship-catppuccin.toml"
      link_entry "$BACKPACK_ROOT/dotfiles/starship/starship-dragon.toml" "$CONFIG_DIR/starship-dragon.toml"
      link_entry "$BACKPACK_ROOT/dotfiles/starship/starship-tokyo.toml" "$CONFIG_DIR/starship-tokyo.toml"
      ;;
  esac

  case "$INSTALL_TARGET" in
    editor|all)
      link_entry "$BACKPACK_ROOT/dotfiles/nvim" "$CONFIG_DIR/nvim"
      ;;
  esac

  case "$INSTALL_TARGET" in
    terminal|all)
      link_entry "$BACKPACK_ROOT/dotfiles/karabiner" "$CONFIG_DIR/karabiner"
      link_entry "$BACKPACK_ROOT/dotfiles/ghostty" "$CONFIG_DIR/ghostty"
      ;;
  esac

  print_client_reminder
}

if [ "$DIRECT_APPLY" -eq 0 ] && [ "$TARGET_SET" -eq 0 ]; then
  offer_gum_install
  ask_install_target
  printf '\n'
fi

if [ "$DIRECT_APPLY" -eq 1 ]; then
  title
  section 'Checking Backpack'
else
  section 'Checking Backpack'
fi
run_doctor

if [ "$DIRECT_APPLY" -eq 1 ]; then
  section 'Applying changes'
  run_plan
  printf '\n'
  success 'Install complete'
  if [ -d "$backup_dir" ]; then
    printf 'Backups: %s\n' "$backup_dir"
  fi
  exit 0
fi

section 'Preview'
APPLY=0
run_plan

cat <<EOF

No changes were made yet.
EOF
if confirm_apply; then
    APPLY=1
    section 'Applying changes'
    run_plan
else
    printf '\n'
    warn 'Install cancelled. No changes were made.'
    exit 0
fi

printf '\n'
success 'Install complete'
if [ -d "$backup_dir" ]; then
  printf 'Backups: %s\n' "$backup_dir"
fi
