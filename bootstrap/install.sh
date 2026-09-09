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
BACKPACK_AGENTS_DIR=${BACKPACK_AGENTS_DIR:-"$HOME/.agents"}
BACKPACK_CODEX_DIR=${CODEX_HOME:-"$HOME/.codex"}
BACKPACK_CLAUDE_DIR=${CLAUDE_CONFIG_DIR:-"$HOME/.claude"}
BACKPACK_COPILOT_DIR=${COPILOT_HOME:-"$HOME/.copilot"}
BACKPACK_BIN_DIR=${BACKPACK_BIN_DIR:-"$HOME/.local/bin"}
APPLY=0
DIRECT_APPLY=0
PROFILE_MODE=personal
INSTALL_COMPONENT=
INSTALL_TARGET=
TARGET_SET=0
REPLACE_EXISTING=0
DRY_RUN=0
WITH_RTK=1
TARGET_FLAG_COUNT=0
PROFILE_FLAG_COUNT=0
USAGE='Usage: backpack install [cockpit|machine|everything] [target] [--personal|--client] [--dry-run]'

case "${1:-}" in
  cockpit|machine|everything)
    INSTALL_COMPONENT=$1
    shift
    ;;
esac

while [ "${1:-}" != "" ]; do
  case "$1" in
    --personal)
      PROFILE_FLAG_COUNT=$((PROFILE_FLAG_COUNT + 1))
      PROFILE_MODE=personal
      ;;
    --client)
      PROFILE_FLAG_COUNT=$((PROFILE_FLAG_COUNT + 1))
      PROFILE_MODE=client
      ;;
    --codex|--claude|--copilot|--opencode)
      TARGET_FLAG_COUNT=$((TARGET_FLAG_COUNT + 1))
      target=${1#--}
      if [ "$INSTALL_COMPONENT" != cockpit ]; then
        printf '✗ %s requires: backpack install cockpit %s\n' "$1" "$1" >&2
        exit 2
      fi
      INSTALL_TARGET=$target
      TARGET_SET=1
      ;;
    --all-hosts)
      TARGET_FLAG_COUNT=$((TARGET_FLAG_COUNT + 1))
      if [ "$INSTALL_COMPONENT" != cockpit ]; then
        printf '✗ --all-hosts requires: backpack install cockpit --all-hosts\n' >&2
        exit 2
      fi
      INSTALL_TARGET=ai
      TARGET_SET=1
      ;;
    --shell|--editor|--terminal)
      TARGET_FLAG_COUNT=$((TARGET_FLAG_COUNT + 1))
      target=${1#--}
      if [ "$INSTALL_COMPONENT" != machine ]; then
        printf '✗ %s requires: backpack install machine %s\n' "$1" "$1" >&2
        exit 2
      fi
      INSTALL_TARGET=$target
      TARGET_SET=1
      ;;
    --all-machine)
      TARGET_FLAG_COUNT=$((TARGET_FLAG_COUNT + 1))
      if [ "$INSTALL_COMPONENT" != machine ]; then
        printf '✗ --all-machine requires: backpack install machine --all-machine\n' >&2
        exit 2
      fi
      INSTALL_TARGET=machine
      TARGET_SET=1
      ;;
    --replace)
      REPLACE_EXISTING=1
      ;;
    --dry-run)
      DRY_RUN=1
      ;;
    --with-rtk)
      WITH_RTK=1
      ;;
    --without-rtk)
      WITH_RTK=0
      ;;
    *)
      printf '%s\n' "$USAGE" >&2
      exit 2
      ;;
  esac
  shift
done

if [ "$TARGET_FLAG_COUNT" -gt 1 ]; then
  printf '✗ choose exactly one installation target\n' >&2
  exit 2
fi

if [ "$PROFILE_FLAG_COUNT" -gt 1 ]; then
  printf '✗ choose either --personal or --client\n' >&2
  exit 2
fi

if [ "$INSTALL_COMPONENT" = everything ]; then
  INSTALL_TARGET=all
  TARGET_SET=1
fi

if [ "$TARGET_SET" -eq 1 ] && [ "$DRY_RUN" -eq 0 ]; then
  APPLY=1
  DIRECT_APPLY=1
fi

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

detail() {
  if [ "${BACKPACK_DETAILS:-0}" -eq 1 ]; then
    info "$1"
  fi
}

detail_success() {
  if [ "${BACKPACK_DETAILS:-0}" -eq 1 ]; then
    success "$1"
  fi
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

install_rtk() {
  if command -v rtk >/dev/null 2>&1; then
    success 'rtk already installed'
    return
  fi

  if ! command -v brew >/dev/null 2>&1; then
    printf '✗ rtk is enabled by default but Homebrew is unavailable; install Homebrew or rtk manually, or rerun with --without-rtk\n' >&2
    exit 1
  fi

  if [ "$APPLY" -eq 0 ]; then
    info 'install rtk via Homebrew'
    return
  fi

  if brew install rtk; then
    command -v rtk >/dev/null 2>&1 || {
      printf '✗ rtk installation completed but rtk is not on PATH\n' >&2
      exit 1
    }
    success 'rtk installed'
  else
    printf '✗ could not install rtk via Homebrew\n' >&2
    exit 1
  fi
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

gum_choose_component() {
  gum_header

  selection=$(gum choose \
    --header 'What do you want to install?' \
    --cursor '→ ' \
    --selected-prefix '✓ ' \
    --unselected-prefix '  ' \
    'Cockpit      AI workflow for supported assistants' \
    'This Mac     Shell, editor, terminal, and personal tools' \
    'Everything   Cockpit and this Mac' \
    'Quit') || {
      warn 'Install cancelled. No changes were made.'
      exit 0
    }

  case $selection in
    Cockpit*) INSTALL_COMPONENT=cockpit ;;
    'This Mac'*) INSTALL_COMPONENT=machine ;;
    Everything*)
      INSTALL_COMPONENT=everything
      INSTALL_TARGET=all
      TARGET_SET=1
      ;;
    Quit)
      warn 'Install cancelled. No changes were made.'
      exit 0
      ;;
  esac
}

gum_choose_cockpit_target() {
  selection=$(gum choose \
    --header 'Where do you want to use Cockpit?' \
    --cursor '→ ' \
    --selected-prefix '✓ ' \
    --unselected-prefix '  ' \
    'OpenCode        Terminal · Desktop app · GitHub Action' \
    'Codex           Terminal · Desktop app' \
    'Claude Code     Terminal · Desktop app (Code tab)' \
    'GitHub Copilot  Terminal · Desktop app' \
    'All supported tools' \
    'Back') || {
      warn 'Install cancelled. No changes were made.'
      exit 0
    }

  case $selection in
    OpenCode*) INSTALL_TARGET=opencode ;;
    Codex*) INSTALL_TARGET=codex ;;
    'Claude Code'*) INSTALL_TARGET=claude ;;
    'GitHub Copilot'*) INSTALL_TARGET=copilot ;;
    'All supported'*) INSTALL_TARGET=ai ;;
    Back)
      INSTALL_COMPONENT=
      return 1
      ;;
  esac
  TARGET_SET=1
}

gum_choose_machine_target() {
  selection=$(gum choose \
    --header 'What do you want to configure on this Mac?' \
    --cursor '→ ' \
    --selected-prefix '✓ ' \
    --unselected-prefix '  ' \
    'Shell      Fish · Starship' \
    'Editor     Neovim' \
    'Terminal   Ghostty · Karabiner' \
    'All machine configuration' \
    'Back') || {
      warn 'Install cancelled. No changes were made.'
      exit 0
    }

  case $selection in
    Shell*) INSTALL_TARGET=shell ;;
    Editor*) INSTALL_TARGET=editor ;;
    Terminal*) INSTALL_TARGET=terminal ;;
    'All machine'*) INSTALL_TARGET=machine ;;
    Back)
      INSTALL_COMPONENT=
      return 1
      ;;
  esac
  TARGET_SET=1
}

confirm_apply() {
  confirmation="Install/update $(target_description) now?"
  if use_gum; then
    gum confirm "$confirmation" && return 0
    return 1
  fi

  choice_prompt "$confirmation [y/N] "
  read answer
  case $answer in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

ask_component() {
  cat <<EOF
$(title)
Portable setup for a fresh machine.

What do you want to install?

  1  Cockpit      AI workflow for supported assistants
  2  This Mac     Shell, editor, terminal, and personal tools
  3  Everything   Cockpit and this Mac
  q  Quit

EOF

  choice_prompt 'Select an option: '
  read choice

  case "$choice" in
    1) INSTALL_COMPONENT=cockpit ;;
    2) INSTALL_COMPONENT=machine ;;
    3)
      INSTALL_COMPONENT=everything
      INSTALL_TARGET=all
      TARGET_SET=1
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

ask_cockpit_target() {
  cat <<EOF

Where do you want to use Cockpit?

  1  OpenCode        Terminal · Desktop app · GitHub Action
  2  Codex           Terminal · Desktop app
  3  Claude Code     Terminal · Desktop app (Code tab)
  4  GitHub Copilot  Terminal · Desktop app
  5  All supported tools
  b  Back

EOF

  choice_prompt 'Select an option: '
  read choice

  case "$choice" in
    1) INSTALL_TARGET=opencode ;;
    2) INSTALL_TARGET=codex ;;
    3) INSTALL_TARGET=claude ;;
    4) INSTALL_TARGET=copilot ;;
    5) INSTALL_TARGET=ai ;;
    b|B)
      INSTALL_COMPONENT=
      return 1
      ;;
    *)
      printf '✗ invalid choice: %s\n' "$choice" >&2
      exit 2
      ;;
  esac
  TARGET_SET=1
}

ask_machine_target() {
  cat <<EOF

What do you want to configure on this Mac?

  1  Shell      Fish · Starship
  2  Editor     Neovim
  3  Terminal   Ghostty · Karabiner
  4  All machine configuration
  b  Back

EOF

  choice_prompt 'Select an option: '
  read choice

  case "$choice" in
    1) INSTALL_TARGET=shell ;;
    2) INSTALL_TARGET=editor ;;
    3) INSTALL_TARGET=terminal ;;
    4) INSTALL_TARGET=machine ;;
    b|B)
      INSTALL_COMPONENT=
      return 1
      ;;
    *)
      printf '✗ invalid choice: %s\n' "$choice" >&2
      exit 2
      ;;
  esac
  TARGET_SET=1
}

ask_install_target() {
  while [ "$TARGET_SET" -eq 0 ]; do
    if [ -z "$INSTALL_COMPONENT" ]; then
      if use_gum; then
        gum_choose_component
      else
        ask_component
      fi
    fi

    case "$INSTALL_COMPONENT" in
      cockpit)
        if use_gum; then
          gum_choose_cockpit_target || continue
        else
          ask_cockpit_target || continue
        fi
        ;;
      machine)
        if use_gum; then
          gum_choose_machine_target || continue
        else
          ask_machine_target || continue
        fi
        ;;
      everything)
        INSTALL_TARGET=all
        TARGET_SET=1
        ;;
    esac
  done
}

backup_existing() {
  target_path=$1

  case "$target_path" in
    /*) backup_path="$backup_dir$target_path" ;;
    *) backup_path="$backup_dir/$target_path" ;;
  esac
  mkdir -p "$(dirname "$backup_path")"
  mv "$target_path" "$backup_path"
  LAST_BACKUP_PATH=$backup_path
  detail "backup $target_path -> $backup_path"
}

copy_dir() {
  source_path=$1
  target_path=$2

  mkdir -p "$(dirname "$target_path")"
  cp -R "$source_path" "$target_path"
  detail_success "copied $target_path"
}

copy_path_with_backup() {
  source_path=$1
  target_path=$2

  if [ "$APPLY" -eq 0 ]; then
    detail "replace $target_path from $source_path"
    return
  fi

  if [ -e "$target_path" ] || [ -L "$target_path" ]; then
    backup_existing "$target_path"
  fi

  mkdir -p "$(dirname "$target_path")"
  cp -R "$source_path" "$target_path"
  detail_success "updated $target_path"
}

skills_source_dir() {
  printf '%s' "$BACKPACK_ROOT/cockpit/portable/skills"
}

skill_is_core() {
  core_candidate=$1
  core_manifest="$BACKPACK_ROOT/cockpit/portable/skills.core"

  while IFS= read -r manifest_line || [ -n "$manifest_line" ]; do
    manifest_entry=${manifest_line%%#*}
    manifest_entry=$(printf '%s' "$manifest_entry" | tr -d ' \t')
    [ -n "$manifest_entry" ] || continue
    [ "$manifest_entry" = "$core_candidate" ] && return 0
  done < "$core_manifest"

  return 1
}

count_core_skills() {
  count_total=0
  for count_path in "$(skills_source_dir)"/*; do
    [ -d "$count_path" ] || continue
    count_name=$(basename "$count_path")
    skill_is_core "$count_name" || continue
    count_total=$((count_total + 1))
  done
  printf '%s' "$count_total"
}

core_install_description() {
  core_count=$(count_core_skills)
  case "$INSTALL_TARGET" in
    copilot) printf '%s explicit /cockpit-* utility skill(s)' "$core_count" ;;
    ai|all) printf '%s workflow skill(s); explicit-only in Copilot' "$core_count" ;;
    *) printf '%s workflow skill(s); specialized skills are project-local' "$core_count" ;;
  esac
}

target_uses_skills() {
  case "$INSTALL_TARGET" in
    ai|all|codex|claude|copilot|opencode) return 0 ;;
    *) return 1 ;;
  esac
}

# Install only the workflow skills required by Cockpit. Specialized skills are
# project-local and managed separately through `backpack add` / `backpack remove`.
install_core_skills() {
  skills_dest=$1
  skills_dir=$(skills_source_dir)

  if [ ! -d "$skills_dir" ]; then
    printf '✗ missing portable skills: %s\n' "$skills_dir" >&2
    exit 1
  fi

  # Earlier Backpack releases linked the whole catalogue as one symlink. Writing
  # per-skill links through it would create entries inside the repository, so
  # replace it with a real directory first.
  if [ -L "$skills_dest" ]; then
    if [ "$APPLY" -eq 0 ]; then
      detail "replace catalogue symlink $skills_dest with a directory"
    else
      mkdir -p "$backup_dir"
      backup_existing "$skills_dest"
    fi
  fi

  [ "$APPLY" -eq 1 ] && mkdir -p "$skills_dest"

  # These names were core skills before Cockpit adopted a consistent public
  # prefix. They are Backpack-managed paths, so move any previous contents to
  # the normal recovery backup before linking their replacements.
  for legacy_skill in prompt-refinement pattern-scan pattern-capture; do
    legacy_path="$skills_dest/$legacy_skill"
    [ -e "$legacy_path" ] || [ -L "$legacy_path" ] || continue
    if [ "$APPLY" -eq 1 ]; then
      backup_existing "$legacy_path"
    else
      detail "migrate legacy Cockpit skill $legacy_path"
    fi
  done

  # Remove legacy Backpack-owned specialized skill links from the global catalogue.
  # Non-core paths belong to other installers and stay outside this install map.
  for installed_path in "$skills_dest"/*; do
    [ -L "$installed_path" ] || continue
    installed_target=$(readlink "$installed_path")
    case "$installed_target" in
      "$skills_dir"/*)
        installed_name=$(basename "$installed_path")
        if ! skill_is_core "$installed_name"; then
          if [ "$APPLY" -eq 1 ]; then
            rm "$installed_path"
          else
            detail "remove legacy global skill link $installed_path"
          fi
        fi
        ;;
    esac
  done

  for skill_path in "$skills_dir"/*; do
    [ -d "$skill_path" ] || continue
    skill_name=$(basename "$skill_path")
    skill_is_core "$skill_name" || continue
    link_entry "$skill_path" "$skills_dest/$skill_name"
  done
}

install_claude_adapter() {
  source_root=$BACKPACK_ROOT/cockpit/adapters/claude

  if [ ! -d "$source_root/agents" ]; then
    printf '✗ missing Claude adapter: %s\n' "$source_root/agents" >&2
    exit 1
  fi

  if [ "$APPLY" -eq 0 ]; then
    detail "replace Claude rules, agents, and the Cockpit core in $BACKPACK_CLAUDE_DIR"
    return
  fi

  mkdir -p "$BACKPACK_CLAUDE_DIR/rules"
  link_entry "$BACKPACK_ROOT/cockpit/portable/AGENTS.md" "$BACKPACK_CLAUDE_DIR/rules/backpack.md"

  install_core_skills "$BACKPACK_CLAUDE_DIR/skills"

  link_entry "$source_root/agents" "$BACKPACK_CLAUDE_DIR/agents"
  detail_success "Claude adapter linked at $BACKPACK_CLAUDE_DIR"
}

install_codex_adapter() {
  source_root=$BACKPACK_ROOT/cockpit/adapters/codex

  if [ ! -d "$source_root/agents" ]; then
    printf '✗ missing Codex adapter agents: %s\n' "$source_root/agents" >&2
    exit 1
  fi

  link_entry "$BACKPACK_ROOT/cockpit/portable/AGENTS.md" "$BACKPACK_CODEX_DIR/AGENTS.md"
  install_core_skills "$BACKPACK_AGENTS_DIR/skills"

  for agent_file in "$source_root"/agents/*.toml; do
    [ -f "$agent_file" ] || continue
    link_entry "$agent_file" "$BACKPACK_CODEX_DIR/agents/$(basename "$agent_file")"
  done
}

configure_rtk_claude() {
  if [ "$APPLY" -eq 0 ]; then
    detail 'configure RTK Claude Code hook'
    return
  fi

  mkdir -p "$BACKPACK_CLAUDE_DIR"

  if rtk init -g --hook-only --auto-patch; then
    detail_success 'RTK Claude Code hook configured'
  else
    warn 'could not configure the RTK Claude Code hook; shared rules remain active'
  fi
}

remove_legacy_copilot_rtk_hook() {
  legacy_hook="$BACKPACK_COPILOT_DIR/hooks/rtk-rewrite.json"

  [ -f "$legacy_hook" ] || return 0
  grep -q '"command": "rtk hook copilot"' "$legacy_hook" || return 0

  if [ "$APPLY" -eq 0 ]; then
    detail "remove legacy Backpack RTK Copilot hook at $legacy_hook"
    return
  fi

  mkdir -p "$backup_dir"
  backup_existing "$legacy_hook"
  detail_success "removed legacy Backpack RTK Copilot hook at $legacy_hook"
}

link_entry() {
  source_path=$1
  target_path=$2

  if [ ! -e "$source_path" ]; then
    printf '✗ missing source: %s\n' "$source_path" >&2
    exit 1
  fi

  if [ "$APPLY" -eq 0 ]; then
    detail "link $target_path -> $source_path"
    return
  fi

  mkdir -p "$(dirname "$target_path")"

  if [ -L "$target_path" ]; then
    current=$(readlink "$target_path")
    if [ "$current" = "$source_path" ]; then
      detail_success "already linked $target_path"
      return
    fi
  fi

  if [ -e "$target_path" ] || [ -L "$target_path" ]; then
    mkdir -p "$backup_dir"
    backup_existing "$target_path"
  fi

  ln -s "$source_path" "$target_path"
  detail_success "linked $target_path"
}

remove_legacy_bp_alias() {
  alias_path="$BACKPACK_BIN_DIR/bp"
  [ -e "$alias_path" ] || [ -L "$alias_path" ] || return 0

  if [ -L "$alias_path" ] && [ "$(readlink "$alias_path")" = "$BACKPACK_ROOT/backpack" ]; then
    if [ "$APPLY" -eq 1 ]; then
      rm "$alias_path"
      detail_success "removed legacy command alias $alias_path"
    else
      detail "remove legacy command alias $alias_path"
    fi
  else
    warn "preserving non-Backpack command at $alias_path"
  fi
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
      detail "replace existing $target_path"
      return
    fi

    backup_existing "$target_path"
    copy_dir "$source_path" "$target_path"
    return
  fi

  if [ "$APPLY" -eq 0 ]; then
    detail "copy $source_path -> $target_path"
    return
  fi

  copy_dir "$source_path" "$target_path"
}

print_client_reminder() {
  if [ "$PROFILE_MODE" = "client" ]; then
    printf '\nClient mode reminder:\n'

    case "$INSTALL_TARGET" in
      ai|opencode|all)
        printf '%s\n' \
          '- Backpack installs the OpenCode adapter and links the shared AI core.' \
          "- Client-only edits in $CONFIG_DIR/opencode are temporary and will be backed up, then replaced, by the next install."
        ;;
    esac

    case "$INSTALL_TARGET" in
      ai|copilot|all)
        printf '%s\n' '- Copilot gets explicit /cockpit-* utilities only; its default workflow and repository instructions remain externally owned.'
        ;;
    esac

    printf '%s\n' '- Do not commit client providers, tokens, endpoints, or policies to Backpack.'
  fi
}

run_doctor() {
  BACKPACK_DOCTOR_QUIET=1 BACKPACK_ROOT=$BACKPACK_ROOT "$SCRIPT_DIR/doctor.sh"
  success 'Backpack health check passed'
}

target_description() {
  case "$INSTALL_TARGET" in
    opencode) printf 'Cockpit for OpenCode' ;;
    codex) printf 'Cockpit for Codex' ;;
    claude) printf 'Cockpit for Claude Code' ;;
    copilot) printf 'Explicit Cockpit utilities for GitHub Copilot' ;;
    ai) printf 'Cockpit for all supported tools' ;;
    shell) printf 'Shell configuration' ;;
    editor) printf 'Editor configuration' ;;
    terminal) printf 'Terminal configuration' ;;
    machine) printf 'All machine configuration' ;;
    all) printf 'Everything in Backpack' ;;
  esac
}

target_surface() {
  case "$INSTALL_TARGET" in
    opencode) printf 'Terminal · Desktop app · GitHub Action' ;;
    codex) printf 'Terminal · Desktop app' ;;
    claude) printf 'Terminal · Desktop app (Code tab)' ;;
    copilot) printf 'Terminal · Desktop app' ;;
    ai) printf 'All supported terminal and desktop surfaces' ;;
    shell) printf 'Fish · Starship' ;;
    editor) printf 'Neovim' ;;
    terminal) printf 'Ghostty · Karabiner' ;;
    machine) printf 'Shell · Editor · Terminal' ;;
    all) printf 'Cockpit · Shell · Editor · Terminal' ;;
  esac
}

print_completion() {
  case "$INSTALL_TARGET" in
    opencode|codex|claude)
      success "$(target_description) installed"
      printf 'Restart the app to activate it.\n'
      ;;
    copilot)
      success 'Explicit Cockpit utilities for GitHub Copilot installed'
      printf 'Reload Copilot skills to activate them.\n'
      ;;
    ai)
      success 'Cockpit installed for all supported tools'
      printf 'Restart the apps to activate it.\n'
      ;;
    *) success "$(target_description) installed" ;;
  esac

  case ":$PATH:" in
    *":$BACKPACK_BIN_DIR:"*) ;;
    *) printf 'To run backpack from anywhere, add %s to PATH.\n' "$BACKPACK_BIN_DIR" ;;
  esac
}

run_plan() {
  cat <<EOF
$(section 'Installation summary')

  Target    $(target_description)
  Surfaces  $(target_surface)
  Action    Refresh links and replace selected adapters from this Backpack version
  Core      $(if target_uses_skills; then core_install_description; else printf 'not applicable'; fi)
  Mode      $(if [ "$APPLY" -eq 1 ]; then printf 'applying'; elif [ "$DRY_RUN" -eq 1 ]; then printf 'dry run'; else printf 'awaiting confirmation'; fi)

EOF

  link_entry "$BACKPACK_ROOT/backpack" "$BACKPACK_BIN_DIR/backpack"
  remove_legacy_bp_alias

  if [ "$WITH_RTK" -eq 1 ]; then
    case "$INSTALL_TARGET" in
      ai|all)
        install_rtk
        configure_rtk_claude
        ;;
      codex)
        install_rtk
        ;;
      claude)
        install_rtk
        configure_rtk_claude
        ;;
      copilot)
        install_rtk
        ;;
      opencode)
        install_rtk
        ;;
    esac
  fi

  case "$INSTALL_TARGET" in
    ai|all|copilot) remove_legacy_copilot_rtk_hook ;;
  esac

  if [ "$REPLACE_EXISTING" -eq 1 ]; then
    warn '--replace is no longer needed; installs always replace Backpack-managed targets.'
  fi

  case "$INSTALL_TARGET" in
    ai|opencode|all)
      copy_dir_once "$BACKPACK_ROOT/cockpit/adapters/opencode" "$CONFIG_DIR/opencode"
      ;;
  esac

  case "$INSTALL_TARGET" in
    opencode)
      link_entry "$BACKPACK_ROOT/cockpit/portable/AGENTS.md" "$CONFIG_DIR/opencode/AGENTS.md"
      install_core_skills "$BACKPACK_AGENTS_DIR/skills"
      ;;
    codex)
      install_codex_adapter
      ;;
    claude)
      install_core_skills "$BACKPACK_AGENTS_DIR/skills"
      install_claude_adapter
      ;;
    copilot)
      install_core_skills "$BACKPACK_AGENTS_DIR/skills"
      ;;
    ai|all)
      link_entry "$BACKPACK_ROOT/cockpit/portable/AGENTS.md" "$CONFIG_DIR/opencode/AGENTS.md"
      install_codex_adapter
      install_claude_adapter
      ;;
  esac

  case "$INSTALL_TARGET" in
    shell|machine|all)
      link_entry "$BACKPACK_ROOT/dotfiles/fish" "$CONFIG_DIR/fish"
      link_entry "$BACKPACK_ROOT/dotfiles/starship/starship.toml" "$CONFIG_DIR/starship.toml"
      link_entry "$BACKPACK_ROOT/dotfiles/starship/starship-catppuccin.toml" "$CONFIG_DIR/starship-catppuccin.toml"
      link_entry "$BACKPACK_ROOT/dotfiles/starship/starship-dragon.toml" "$CONFIG_DIR/starship-dragon.toml"
      link_entry "$BACKPACK_ROOT/dotfiles/starship/starship-tokyo.toml" "$CONFIG_DIR/starship-tokyo.toml"
      ;;
  esac

  case "$INSTALL_TARGET" in
    editor|machine|all)
      link_entry "$BACKPACK_ROOT/dotfiles/nvim" "$CONFIG_DIR/nvim"
      ;;
  esac

  case "$INSTALL_TARGET" in
    terminal|machine|all)
      link_entry "$BACKPACK_ROOT/dotfiles/karabiner" "$CONFIG_DIR/karabiner"
      link_entry "$BACKPACK_ROOT/dotfiles/ghostty" "$CONFIG_DIR/ghostty"
      ;;
  esac

  print_client_reminder
}

if [ "$DIRECT_APPLY" -eq 0 ]; then
  if [ "$TARGET_SET" -eq 0 ]; then
    offer_gum_install
    ask_install_target
    printf '\n'
  fi
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
  print_completion
  if [ -d "$backup_dir" ]; then
    printf 'Backups: %s\n' "$backup_dir"
  fi
  exit 0
fi

if [ "$DRY_RUN" -eq 1 ]; then
  section 'Preview'
else
  section 'Ready to install/update'
fi
APPLY=0
run_plan

if [ "$DRY_RUN" -eq 1 ]; then
  printf '\n'
  success 'Dry run complete. No changes were made.'
  exit 0
fi

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
print_completion
if [ -d "$backup_dir" ]; then
  printf 'Backups: %s\n' "$backup_dir"
fi
