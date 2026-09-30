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
if [ "${SUPER_CONFIG_DIR+x}" = x ]; then
  BACKPACK_SUPER_DIR=$SUPER_CONFIG_DIR
  SUPER_CONFIG_EXPLICIT=1
else
  BACKPACK_SUPER_DIR=$HOME/.super.engineering
  SUPER_CONFIG_EXPLICIT=0
fi
BACKPACK_BIN_DIR=${BACKPACK_BIN_DIR:-"$HOME/.local/bin"}
BACKPACK_STATE_FILE=${BACKPACK_STATE_FILE:-"$CONFIG_DIR/backpack/installed-components"}
BACKPACK_REVISION_FILE=${BACKPACK_REVISION_FILE:-"$CONFIG_DIR/backpack/installed-revisions"}
APPLY=0
DIRECT_APPLY=0
PROFILE_MODE=personal
INSTALL_COMPONENT=
LEGACY_COMPONENT=0
INSTALL_TARGET=
TARGET_SET=0
REPLACE_EXISTING=0
DRY_RUN=0
WITH_RTK=1
TARGET_FLAG_COUNT=0
PROFILE_FLAG_COUNT=0
USAGE='Usage: backpack install [engineering|cockpit|machine|everything] [target] [--personal|--client] [--dry-run]'

case "${1:-}" in
  engineering|machine|everything)
    INSTALL_COMPONENT=$1
    shift
    ;;
  cockpit)
    INSTALL_COMPONENT=engineering
    LEGACY_COMPONENT=1
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
    --codex|--claude|--opencode|--super)
      TARGET_FLAG_COUNT=$((TARGET_FLAG_COUNT + 1))
      target=${1#--}
      if [ "$INSTALL_COMPONENT" != engineering ]; then
        printf '✗ %s requires: backpack install engineering %s\n' "$1" "$1" >&2
        exit 2
      fi
      INSTALL_TARGET=$target
      TARGET_SET=1
      ;;
    --copilot)
      printf '✗ GitHub Copilot is client-owned and is not installed by Backpack.\n' >&2
      exit 2
      ;;
    --all-hosts)
      TARGET_FLAG_COUNT=$((TARGET_FLAG_COUNT + 1))
      if [ "$INSTALL_COMPONENT" != engineering ]; then
        printf '✗ --all-hosts requires: backpack install engineering --all-hosts\n' >&2
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
    '◆ Backpack' 'Install or refresh from this checkout.'
}

gum_choose_component() {
  gum_header

  selection=$(gum choose \
    --header 'What do you want to install or refresh?' \
    --cursor '→ ' \
    --selected-prefix '✓ ' \
    --unselected-prefix '  ' \
    'Backpack Engineering      AI workflow for supported assistants' \
    'This Mac     Shell, editor, terminal, and personal tools' \
    'Everything   Backpack Engineering and this Mac' \
    'Quit') || {
      warn 'Install cancelled. No changes were made.'
      exit 0
    }

  case $selection in
    'Backpack Engineering'*) INSTALL_COMPONENT=engineering ;;
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

gum_choose_backpack_target() {
  selection=$(gum choose \
    --header 'Which tool should Backpack Engineering configure?' \
    --cursor '→ ' \
    --selected-prefix '✓ ' \
    --unselected-prefix '  ' \
    'OpenCode        Terminal · Desktop app · GitHub Action' \
    'Codex           Terminal · Desktop app' \
    'Claude Code     Terminal · Desktop app (Code tab)' \
    'Super           Portable control-plane preferences' \
    'All supported tools' \
    'Back') || {
      warn 'Install cancelled. No changes were made.'
      exit 0
    }

  case $selection in
    OpenCode*) INSTALL_TARGET=opencode ;;
    Codex*) INSTALL_TARGET=codex ;;
    'Claude Code'*) INSTALL_TARGET=claude ;;
    Super*) INSTALL_TARGET=super ;;
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
  confirmation="Apply $(target_description) from this checkout now?"
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
Install or refresh from this checkout.

What do you want to install or refresh?

  1  Backpack Engineering      AI workflow for supported assistants
  2  This Mac     Shell, editor, terminal, and personal tools
  3  Everything   Backpack Engineering and this Mac
  q  Quit

EOF

  choice_prompt 'Select an option: '
  read choice

  case "$choice" in
    1) INSTALL_COMPONENT=engineering ;;
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

ask_backpack_target() {
  cat <<EOF

Which tool should Backpack Engineering configure?

  1  OpenCode        Terminal · Desktop app · GitHub Action
  2  Codex           Terminal · Desktop app
  3  Claude Code     Terminal · Desktop app (Code tab)
  4  Super           Portable control-plane preferences
  5  All supported tools
  b  Back

EOF

  choice_prompt 'Select an option: '
  read choice

  case "$choice" in
    1) INSTALL_TARGET=opencode ;;
    2) INSTALL_TARGET=codex ;;
    3) INSTALL_TARGET=claude ;;
    4) INSTALL_TARGET=super ;;
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
      engineering)
        if use_gum; then
          gum_choose_backpack_target || continue
        else
          ask_backpack_target || continue
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
  printf '%s' "$BACKPACK_ROOT/engineering/portable/skills"
}

skill_is_core() {
  core_candidate=$1
  core_manifest="$BACKPACK_ROOT/engineering/portable/skills.core"

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
  printf '%s workflow skill(s); specialized skills are project-local' "$core_count"
}

target_uses_skills() {
  case "$INSTALL_TARGET" in
    ai|all|codex|claude|opencode) return 0 ;;
    *) return 1 ;;
  esac
}

# Install only the workflow skills required by Backpack Engineering. Specialized skills are
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

  # These names were core skills before Backpack Engineering adopted a consistent public
  # prefix. They are Backpack-managed paths, so move any previous contents to
  # the normal recovery backup before linking their replacements.
  for legacy_skill in \
    prompt-refinement \
    cockpit-prompt-refinement \
    cockpit-enhance-prompt \
    cockpit-pattern-scan \
    cockpit-pattern-capture \
    cockpit-validate \
    cockpit-learn \
    cockpit-start-work \
    pattern-scan \
    pattern-capture; do
    legacy_path="$skills_dest/$legacy_skill"
    [ -e "$legacy_path" ] || [ -L "$legacy_path" ] || continue
    if [ "$APPLY" -eq 1 ]; then
      backup_existing "$legacy_path"
    else
      detail "migrate legacy Backpack Engineering skill $legacy_path"
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
  source_root=$BACKPACK_ROOT/engineering/adapters/claude

  if [ ! -d "$source_root/agents" ]; then
    printf '✗ missing Claude adapter: %s\n' "$source_root/agents" >&2
    exit 1
  fi

  if [ "$APPLY" -eq 0 ]; then
    detail "replace Claude rules, agents, and the Backpack Engineering core in $BACKPACK_CLAUDE_DIR"
    return
  fi

  mkdir -p "$BACKPACK_CLAUDE_DIR/rules"
  link_entry "$BACKPACK_ROOT/engineering/portable/AGENTS.md" "$BACKPACK_CLAUDE_DIR/rules/backpack.md"

  install_core_skills "$BACKPACK_CLAUDE_DIR/skills"

  link_entry "$source_root/agents" "$BACKPACK_CLAUDE_DIR/agents"
  detail_success "Claude adapter linked at $BACKPACK_CLAUDE_DIR"
}

install_codex_adapter() {
  source_root=$BACKPACK_ROOT/engineering/adapters/codex

  if [ ! -d "$source_root/agents" ]; then
    printf '✗ missing Codex adapter agents: %s\n' "$source_root/agents" >&2
    exit 1
  fi

  link_entry "$BACKPACK_ROOT/engineering/portable/AGENTS.md" "$BACKPACK_CODEX_DIR/AGENTS.md"
  install_core_skills "$BACKPACK_AGENTS_DIR/skills"

  for legacy_agent in cockpit-code-review.toml cockpit-product-qa.toml; do
    legacy_path="$BACKPACK_CODEX_DIR/agents/$legacy_agent"
    [ -e "$legacy_path" ] || [ -L "$legacy_path" ] || continue
    if [ "$APPLY" -eq 1 ]; then
      backup_existing "$legacy_path"
    else
      detail "migrate legacy Backpack Engineering agent $legacy_path"
    fi
  done

  for agent_file in "$source_root"/agents/*.toml; do
    [ -f "$agent_file" ] || continue
    link_entry "$agent_file" "$BACKPACK_CODEX_DIR/agents/$(basename "$agent_file")"
  done
}

merge_json_config() {
  source_path=$1
  target_path=$2

  if [ ! -f "$source_path" ]; then
    printf '✗ missing Super adapter config: %s\n' "$source_path" >&2
    exit 1
  fi

  if [ "$APPLY" -eq 0 ]; then
    detail "merge portable Super settings into $target_path"
    return
  fi

  command -v jq >/dev/null 2>&1 || {
    printf '✗ jq is required to merge Super settings safely; install it with: brew install jq\n' >&2
    exit 1
  }

  mkdir -p "$(dirname "$target_path")"
  if [ ! -e "$target_path" ]; then
    cp "$source_path" "$target_path"
    detail_success "created $target_path"
    return
  fi

  jq -e . "$target_path" >/dev/null 2>&1 || {
    printf '✗ existing Super config is not valid JSON: %s\n' "$target_path" >&2
    exit 1
  }

  merged_path=$(mktemp "${target_path}.backpack.XXXXXX")
  if ! jq -s '.[0] * .[1]' "$target_path" "$source_path" > "$merged_path"; then
    rm -f "$merged_path"
    printf '✗ could not merge Super config: %s\n' "$target_path" >&2
    exit 1
  fi

  backup_existing "$target_path"
  mv "$merged_path" "$target_path"
  detail_success "merged portable settings into $target_path"
}

install_super_adapter() {
  ensure_super_storage
  source_root=$BACKPACK_ROOT/engineering/adapters/super
  validate_json_merge "$source_root/settings.json" "$BACKPACK_SUPER_DIR/settings.json"
  validate_json_merge "$source_root/chat-defaults.json" "$BACKPACK_SUPER_DIR/chat-defaults.json"
  prepare_super_commands
  merge_json_config "$source_root/settings.json" "$BACKPACK_SUPER_DIR/settings.json"
  merge_json_config "$source_root/chat-defaults.json" "$BACKPACK_SUPER_DIR/chat-defaults.json"
  sync_super_commands
}

super_command_descriptor() {
  SUPER_COMMAND_FILE=$BACKPACK_ROOT/engineering/adapters/super/commands/$1.txt
  SUPER_COMMAND_AUTO=true
  case "$1" in
    project-kickoff)
      SUPER_COMMAND_NAME='🧭 Kickoff'
      SUPER_COMMAND_LEGACY_NAME='Backpack · Project kickoff'
      SUPER_COMMAND_OWNERSHIP_TOKEN='backpack-kickoff'
      ;;
    validate-delivery)
      SUPER_COMMAND_NAME='⚖️ Validate'
      SUPER_COMMAND_LEGACY_NAME='Backpack · Validate delivery'
      SUPER_COMMAND_OWNERSHIP_TOKEN='backpack-validate'
      ;;
    learn)
      SUPER_COMMAND_NAME='📚 Learn'
      SUPER_COMMAND_LEGACY_NAME='Backpack · Learn'
      SUPER_COMMAND_OWNERSHIP_TOKEN='backpack-learn'
      ;;
    pattern-scan)
      SUPER_COMMAND_NAME='🔎 Pattern scan'
      SUPER_COMMAND_LEGACY_NAME='Backpack · Pattern scan'
      SUPER_COMMAND_OWNERSHIP_TOKEN='backpack-pattern-scan'
      ;;
    orchestrated-build)
      SUPER_COMMAND_NAME='👥 Team build'
      SUPER_COMMAND_LEGACY_NAME='Backpack · Orchestrated build'
      SUPER_COMMAND_OWNERSHIP_TOKEN="Backpack Engineering's Build"
      SUPER_COMMAND_AUTO=false
      ;;
  esac
}

super_commands_cli() {
  (CDPATH= cd "$SUPER_COMMAND_CWD" && "$BACKPACK_SC_BIN" commands "$@")
}

read_super_commands() {
  SUPER_COMMANDS_JSON=$(super_commands_cli list --scope global --json 2>&1) || return 1
  printf '%s' "$SUPER_COMMANDS_JSON" |
    jq -e '.kind == "custom_commands" and (.response.commands | type == "array")' >/dev/null 2>&1
}

select_super_command_context() {
  super_workspaces_json=$("$BACKPACK_SC_BIN" workspace list --json 2>/dev/null) || return 1
  super_worktree=$(printf '%s' "$super_workspaces_json" | jq -r '
    select(.kind == "workspace_list") |
    [.response.workspaces[]?.sections[]?.projects[]?.items[]? |
      select(.path | type == "string")] as $items |
    ([$items[] | select(.selected == true) | .path][0] //
     [$items[] | .path][0] // empty)
  ' 2>/dev/null) || return 1
  [ -n "$super_worktree" ] && [ -d "$super_worktree" ] || return 1
  SUPER_COMMAND_CWD=$super_worktree
}

prepare_super_commands() {
  if [ "$APPLY" -eq 0 ]; then
    detail 'sync five global Backpack commands through the Super CLI'
    return
  fi
  if [ "$SUPER_CONFIG_EXPLICIT" -eq 1 ]; then
    warn 'Super commands were not synced: SUPER_CONFIG_DIR redirects settings files only'
    return
  fi

  command -v jq >/dev/null 2>&1 || {
    printf '✗ jq is required to sync Super commands safely; install it with: brew install jq\n' >&2
    exit 1
  }
  BACKPACK_SC_BIN=
  if command -v sc >/dev/null 2>&1; then
    BACKPACK_SC_BIN=$(command -v sc)
  elif [ -x "$BACKPACK_SUPER_DIR/bin/sc" ]; then
    BACKPACK_SC_BIN=$BACKPACK_SUPER_DIR/bin/sc
  fi
  if [ -z "$BACKPACK_SC_BIN" ] && command -v open >/dev/null 2>&1 &&
     open -a super.engineering >/dev/null 2>&1; then
    super_wait=0
    while [ "$super_wait" -lt 10 ]; do
      sleep 1
      if [ -x "$BACKPACK_SUPER_DIR/bin/sc" ]; then
        BACKPACK_SC_BIN=$BACKPACK_SUPER_DIR/bin/sc
        break
      fi
      super_wait=$((super_wait + 1))
    done
  fi
  if [ -z "$BACKPACK_SC_BIN" ]; then
    printf '✗ Super CLI not found; install super.engineering before installing its Backpack adapter\n' >&2
    exit 1
  fi

  SUPER_COMMAND_CWD=$BACKPACK_ROOT
  super_commands_ready=0
  if read_super_commands; then
    super_commands_ready=1
  fi
  if [ "$super_commands_ready" -eq 0 ] && select_super_command_context; then
    if read_super_commands; then
      super_commands_ready=1
    fi
  fi
  if [ "$super_commands_ready" -eq 0 ] &&
     command -v open >/dev/null 2>&1 && open -a super.engineering >/dev/null 2>&1; then
    super_wait=0
    while [ "$super_wait" -lt 10 ]; do
      sleep 1
      select_super_command_context || true
      if read_super_commands; then
        super_commands_ready=1
        break
      fi
      super_wait=$((super_wait + 1))
    done
  fi
  if [ "$super_commands_ready" -eq 0 ]; then
    printf '✗ cannot read global Super commands; Super needs a live workspace to sync them\n' >&2
    printf '%s\n' "$SUPER_COMMANDS_JSON" >&2
    exit 1
  fi

  for super_command_key in project-kickoff validate-delivery learn pattern-scan orchestrated-build; do
    super_command_descriptor "$super_command_key"
    if [ ! -s "$SUPER_COMMAND_FILE" ]; then
      printf '✗ missing Backpack Super command: %s\n' "$SUPER_COMMAND_FILE" >&2
      exit 1
    fi
    super_command_count=$(printf '%s' "$SUPER_COMMANDS_JSON" |
      jq -r --arg name "$SUPER_COMMAND_NAME" --arg legacy "$SUPER_COMMAND_LEGACY_NAME" \
        '[.response.commands[] | select(.scope == "global" and (.name == $name or .name == $legacy))] | length')
    if [ "$super_command_count" -gt 1 ]; then
      printf '✗ duplicate global Super command for %s; resolve it in Super before reinstalling\n' "$SUPER_COMMAND_NAME" >&2
      exit 1
    fi
    super_command_owned_count=$(printf '%s' "$SUPER_COMMANDS_JSON" |
      jq -r --arg name "$SUPER_COMMAND_NAME" --arg legacy "$SUPER_COMMAND_LEGACY_NAME" \
        --arg token "$SUPER_COMMAND_OWNERSHIP_TOKEN" \
        '[.response.commands[] | select(.scope == "global" and (.name == $name or .name == $legacy)) | select((.command // "") | contains($token))] | length')
    if [ "$super_command_count" -ne "$super_command_owned_count" ]; then
      printf '✗ Super command name collision: %s; a matching name does not contain the Backpack prompt\n' "$SUPER_COMMAND_NAME" >&2
      exit 1
    fi
  done
}

super_command_matches() {
  printf '%s' "$SUPER_COMMANDS_JSON" | jq -e \
    --arg name "$SUPER_COMMAND_NAME" \
    --arg prompt "$SUPER_COMMAND_PROMPT" \
    --argjson auto "$SUPER_COMMAND_AUTO" \
    '([.response.commands[] | select(.scope == "global" and .name == $name)]) as $matches |
      ($matches | length) == 1 and
      $matches[0].command == $prompt and
      $matches[0].dispatch == "current_chat" and
      $matches[0].view == "chat" and
      $matches[0].auto_submit == $auto' >/dev/null
}

sync_super_commands() {
  [ "$APPLY" -eq 1 ] && [ "$SUPER_CONFIG_EXPLICIT" -eq 0 ] || return 0

  for super_command_key in project-kickoff validate-delivery learn pattern-scan orchestrated-build; do
    super_command_descriptor "$super_command_key"
    SUPER_COMMAND_PROMPT=$(cat "$SUPER_COMMAND_FILE")
    if super_command_matches; then
      detail "kept Super command $SUPER_COMMAND_NAME"
      continue
    fi

    super_command_id=$(printf '%s' "$SUPER_COMMANDS_JSON" |
      jq -r --arg name "$SUPER_COMMAND_NAME" --arg legacy "$SUPER_COMMAND_LEGACY_NAME" \
        '[.response.commands[] | select(.scope == "global" and (.name == $name or .name == $legacy))] | .[0].id // empty')
    if [ -n "$super_command_id" ]; then
      if [ "$SUPER_COMMAND_AUTO" = true ]; then
        super_commands_cli update "$super_command_id" --scope global \
          --name "$SUPER_COMMAND_NAME" --command "$SUPER_COMMAND_PROMPT" --dispatch current-chat --view chat \
          --auto-submit --json >/dev/null
      else
        super_commands_cli update "$super_command_id" --scope global \
          --name "$SUPER_COMMAND_NAME" --command "$SUPER_COMMAND_PROMPT" --dispatch current-chat --view chat \
          --no-auto-submit --json >/dev/null
      fi
      detail_success "updated Super command $SUPER_COMMAND_NAME"
    else
      if [ "$SUPER_COMMAND_AUTO" = true ]; then
        super_commands_cli create "$SUPER_COMMAND_NAME" \
          --command "$SUPER_COMMAND_PROMPT" --scope global \
          --dispatch current-chat --view chat --json >/dev/null
      else
        super_commands_cli create "$SUPER_COMMAND_NAME" \
          --command "$SUPER_COMMAND_PROMPT" --scope global \
          --dispatch current-chat --view chat --no-auto-submit --json >/dev/null
      fi
      detail_success "created Super command $SUPER_COMMAND_NAME"
    fi
  done

  if ! read_super_commands; then
    printf '✗ cannot verify global Super commands after synchronization\n' >&2
    printf '%s\n' "$SUPER_COMMANDS_JSON" >&2
    exit 1
  fi
  for super_command_key in project-kickoff validate-delivery learn pattern-scan orchestrated-build; do
    super_command_descriptor "$super_command_key"
    SUPER_COMMAND_PROMPT=$(cat "$SUPER_COMMAND_FILE")
    if ! super_command_matches; then
      printf '✗ Super command sync could not verify %s\n' "$SUPER_COMMAND_NAME" >&2
      exit 1
    fi
  done
  detail_success 'verified five global Super commands'
}

validate_json_merge() {
  source_path=$1
  target_path=$2

  command -v jq >/dev/null 2>&1 || {
    printf '✗ jq is required to merge Super settings safely; install it with: brew install jq\n' >&2
    exit 1
  }
  jq -e . "$source_path" >/dev/null 2>&1 || {
    printf '✗ Backpack Super config is not valid JSON: %s\n' "$source_path" >&2
    exit 1
  }
  if [ -e "$target_path" ] && ! jq -e . "$target_path" >/dev/null 2>&1; then
    printf '✗ existing Super config is not valid JSON: %s\n' "$target_path" >&2
    exit 1
  fi
}

ensure_super_storage() {
  [ "$SUPER_CONFIG_EXPLICIT" -eq 0 ] || return 0

  old_super_dir=$HOME/.superconductor
  new_super_dir=$HOME/.super.engineering

  if [ "$APPLY" -eq 0 ]; then
    detail "preserve Super storage and use $new_super_dir"
    return
  fi

  if [ -e "$old_super_dir" ] && [ ! -e "$new_super_dir" ] && [ ! -L "$new_super_dir" ]; then
    command -v sc >/dev/null 2>&1 || {
      printf '✗ Super data migration requires the bundled `sc migrate-data` command\n' >&2
      exit 1
    }
    sc migrate-data
    if [ ! -L "$new_super_dir" ] || [ ! -e "$new_super_dir" ]; then
      printf '✗ `sc migrate-data` did not create a valid %s alias; no Super settings were changed\n' "$new_super_dir" >&2
      exit 1
    fi
  fi

  if [ -L "$new_super_dir" ]; then
    alias_target=$(readlink "$new_super_dir")
    if [ ! -e "$new_super_dir" ]; then
      printf '✗ invalid Super data alias: %s -> %s\n' "$new_super_dir" "$alias_target" >&2
      exit 1
    fi
    old_super_real=$(CDPATH= cd "$old_super_dir" && pwd -P)
    new_super_real=$(CDPATH= cd "$new_super_dir" && pwd -P)
    if [ "$new_super_real" != "$old_super_real" ]; then
      printf '✗ invalid Super data alias: %s -> %s\n' "$new_super_dir" "$alias_target" >&2
      exit 1
    fi
  elif [ -e "$old_super_dir" ] && [ -e "$new_super_dir" ]; then
    printf '✗ both Super data folders are independent; keep both and resolve with `sc migrate-data`\n' >&2
    exit 1
  fi

  BACKPACK_SUPER_DIR=$new_super_dir
}

record_installation() {
  recorded_target=$1
  mkdir -p "$(dirname "$BACKPACK_STATE_FILE")"
  state_temp=$(mktemp "${BACKPACK_STATE_FILE}.XXXXXX")
  if [ -f "$BACKPACK_STATE_FILE" ]; then
    awk 'NF' "$BACKPACK_STATE_FILE" > "$state_temp"
  fi
  if [ -e "$CONFIG_DIR/opencode/AGENTS.md" ] || [ -L "$CONFIG_DIR/opencode/AGENTS.md" ]; then printf 'opencode\n' >> "$state_temp"; fi
  if [ -e "$BACKPACK_CODEX_DIR/AGENTS.md" ] || [ -L "$BACKPACK_CODEX_DIR/AGENTS.md" ]; then printf 'codex\n' >> "$state_temp"; fi
  if [ -e "$BACKPACK_CLAUDE_DIR/rules/backpack.md" ] || [ -L "$BACKPACK_CLAUDE_DIR/rules/backpack.md" ]; then printf 'claude\n' >> "$state_temp"; fi
  if [ -e "$BACKPACK_SUPER_DIR/settings.json" ]; then printf 'super\n' >> "$state_temp"; fi
  if [ -e "$CONFIG_DIR/fish" ] || [ -L "$CONFIG_DIR/fish" ]; then printf 'shell\n' >> "$state_temp"; fi
  if [ -e "$CONFIG_DIR/nvim" ] || [ -L "$CONFIG_DIR/nvim" ]; then printf 'editor\n' >> "$state_temp"; fi
  if [ -e "$CONFIG_DIR/ghostty" ] || [ -L "$CONFIG_DIR/ghostty" ]; then printf 'terminal\n' >> "$state_temp"; fi
  printf '%s\n' "$recorded_target" >> "$state_temp"
  sort -u "$state_temp" -o "$state_temp"
  mv "$state_temp" "$BACKPACK_STATE_FILE"
}

read_installed_revision() {
  [ -f "$BACKPACK_REVISION_FILE" ] || return 0
  awk -v target="$1" '$1 == target { print $2; exit }' "$BACKPACK_REVISION_FILE"
}

checkout_revision() {
  command -v git >/dev/null 2>&1 || return 0
  [ -e "$BACKPACK_ROOT/.git" ] || return 0
  git -C "$BACKPACK_ROOT" rev-parse --verify HEAD 2>/dev/null || true
}

record_installation_revision() {
  [ -n "$CURRENT_REVISION" ] || return 0

  case "$INSTALL_TARGET" in
    ai) revision_targets='ai opencode codex claude super' ;;
    machine) revision_targets='machine shell editor terminal' ;;
    all) revision_targets='all ai opencode codex claude super machine shell editor terminal' ;;
    *) revision_targets=$INSTALL_TARGET ;;
  esac

  mkdir -p "$(dirname "$BACKPACK_REVISION_FILE")"
  revision_temp=$(mktemp "${BACKPACK_REVISION_FILE}.XXXXXX")
  if [ -f "$BACKPACK_REVISION_FILE" ]; then
    awk -v targets=" $revision_targets " 'index(targets, " " $1 " ") == 0' \
      "$BACKPACK_REVISION_FILE" > "$revision_temp"
  fi
  for revision_target in $revision_targets; do
    printf '%s %s\n' "$revision_target" "$CURRENT_REVISION" >> "$revision_temp"
  done
  mv "$revision_temp" "$BACKPACK_REVISION_FILE"
}

verify_installation() {
  "$SCRIPT_DIR/check.sh" "$INSTALL_TARGET"
  success 'Installed state verified'
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

    printf '%s\n' \
      '- GitHub Copilot is outside Backpack and remains entirely client-owned.' \
      '- Do not commit client providers, tokens, endpoints, instructions, or policies to Backpack.'
  fi
}

run_doctor() {
  BACKPACK_DOCTOR_QUIET=1 BACKPACK_ROOT=$BACKPACK_ROOT "$SCRIPT_DIR/doctor.sh"
  success 'Backpack health check passed'
}

target_description() {
  case "$INSTALL_TARGET" in
    opencode) printf 'Backpack Engineering for OpenCode' ;;
    codex) printf 'Backpack Engineering for Codex' ;;
    claude) printf 'Backpack Engineering for Claude Code' ;;
    super) printf 'Backpack Engineering preferences for Super' ;;
    ai) printf 'Backpack Engineering for all supported tools' ;;
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
    super) printf 'Super desktop app' ;;
    ai) printf 'All supported terminal and desktop surfaces' ;;
    shell) printf 'Fish · Starship' ;;
    editor) printf 'Neovim' ;;
    terminal) printf 'Ghostty · Karabiner' ;;
    machine) printf 'Shell · Editor · Terminal' ;;
    all) printf 'Backpack Engineering · Shell · Editor · Terminal' ;;
  esac
}

change_paths() {
  set -- backpack bootstrap
  case "$INSTALL_TARGET" in
    opencode|codex|claude)
      set -- "$@" engineering/portable "engineering/adapters/$INSTALL_TARGET"
      ;;
    super) set -- "$@" engineering/adapters/super ;;
    ai) set -- "$@" engineering ;;
    all) set -- "$@" engineering dotfiles ;;
    shell) set -- "$@" dotfiles/fish dotfiles/starship ;;
    editor) set -- "$@" dotfiles/nvim ;;
    terminal) set -- "$@" dotfiles/ghostty dotfiles/karabiner ;;
    machine) set -- "$@" dotfiles ;;
  esac
  CHANGE_PATHS="$*"
}

installed_contents() {
  case "$INSTALL_TARGET" in
    opencode) printf 'portable rules, %s core skills, OpenCode commands and agents' "$(count_core_skills)" ;;
    codex) printf 'portable rules, %s core skills, Codex review agents' "$(count_core_skills)" ;;
    claude) printf 'portable rules, %s core skills, Claude agents' "$(count_core_skills)" ;;
    super)
      if [ "$SUPER_CONFIG_EXPLICIT" -eq 1 ]; then
        printf 'portable Super settings and chat defaults (commands skipped for redirected profile)'
      else
        printf 'portable Super settings, chat defaults, and five Backpack commands'
      fi
      ;;
    ai)
      if [ "$SUPER_CONFIG_EXPLICIT" -eq 1 ]; then
        printf 'portable rules, %s core skills, host adapters, Super preferences' "$(count_core_skills)"
      else
        printf 'portable rules, %s core skills, host adapters, Super preferences and commands' "$(count_core_skills)"
      fi
      ;;
    all)
      if [ "$SUPER_CONFIG_EXPLICIT" -eq 1 ]; then
        printf 'portable rules, %s core skills, host adapters, Super preferences, machine configuration' "$(count_core_skills)"
      else
        printf 'portable rules, %s core skills, host adapters, Super preferences and commands, machine configuration' "$(count_core_skills)"
      fi
      ;;
    shell) printf 'Fish and Starship configuration' ;;
    editor) printf 'Neovim configuration' ;;
    terminal) printf 'Ghostty and Karabiner configuration' ;;
    machine) printf 'shell, editor, and terminal configuration' ;;
  esac
}

print_install_changes() {
  section 'Installed in this run'
  info "$(installed_contents)"
  case "$INSTALL_TARGET" in
    super)
      muted 'Workflow skills use the provider adapter; refresh that provider separately.'
      ;;
  esac
  case "$INSTALL_TARGET" in
    super|ai|all)
      if [ "$SUPER_CONFIG_EXPLICIT" -eq 0 ]; then
        muted 'Super commands: 🧭 Kickoff, 👥 Team build, ⚖️ Validate, 📚 Learn, 🔎 Pattern scan'
      fi
      ;;
  esac

  if [ -z "$CURRENT_REVISION" ]; then
    muted 'Change history unavailable outside a Git checkout.'
    return
  fi

  change_paths
  # Paths are repository-owned names selected above; whitespace is not valid in them.
  set -- $CHANGE_PATHS

  if [ -n "$PREVIOUS_REVISION" ] &&
     git -C "$BACKPACK_ROOT" cat-file -e "$PREVIOUS_REVISION^{commit}" 2>/dev/null &&
     git -C "$BACKPACK_ROOT" merge-base --is-ancestor "$PREVIOUS_REVISION" "$CURRENT_REVISION" 2>/dev/null; then
    if [ "$PREVIOUS_REVISION" = "$CURRENT_REVISION" ]; then
      muted 'No new committed changes since the last install of this target.'
    else
      change_range="$PREVIOUS_REVISION..$CURRENT_REVISION"
      change_count=$(git -C "$BACKPACK_ROOT" rev-list --count --no-merges "$change_range" -- "$@")
      if [ "$change_count" -eq 0 ]; then
        muted 'No new committed changes for this target.'
      else
        section "New since the last $(target_description) install"
        git -C "$BACKPACK_ROOT" log --no-merges --max-count=4 --format='  • %s' "$change_range" -- "$@"
        if [ "$change_count" -gt 4 ]; then
          muted "  + $((change_count - 4)) more commit(s)"
        fi
      fi
    fi
  else
    section 'Recent changes in this checkout'
    if [ -z "$PREVIOUS_REVISION" ]; then
      muted 'First tracked install for this target; these may already be installed.'
    else
      muted 'Previous revision is outside this Git history; these may already be installed.'
    fi
    git -C "$BACKPACK_ROOT" log --no-merges --max-count=4 --format='  • %s' "$CURRENT_REVISION" -- "$@"
  fi

  if [ -n "$(git -C "$BACKPACK_ROOT" status --porcelain --untracked-files=normal -- "$@")" ]; then
    warn 'Local uncommitted changes are present; commit notes do not describe them.'
  fi
}

print_completion() {
  case "$INSTALL_TARGET" in
    opencode|codex|claude|super)
      success "$(target_description) installed"
      printf 'Restart the app to activate it.\n'
      ;;
    ai)
      success 'Backpack Engineering installed for all supported tools'
      printf 'Restart the apps to activate it.\n'
      ;;
    *) success "$(target_description) installed" ;;
  esac

  print_install_changes

  case ":$PATH:" in
    *":$BACKPACK_BIN_DIR:"*) ;;
    *) printf 'To run backpack from anywhere, add %s to PATH.\n' "$BACKPACK_BIN_DIR" ;;
  esac
}

run_plan() {
  cat <<EOF
$(section 'Installation summary')

  Target    $(target_description)
  Source    $BACKPACK_ROOT
  Surfaces  $(target_surface)
  Action    Refresh links and replace selected adapters from this Backpack version
  Core      $(if target_uses_skills; then core_install_description; else printf 'not applicable'; fi)
  Mode      $(if [ "$APPLY" -eq 1 ]; then printf 'applying'; elif [ "$DRY_RUN" -eq 1 ]; then printf 'dry run'; else printf 'awaiting confirmation'; fi)

EOF

  if [ "$APPLY" -eq 0 ] && [ -n "$CURRENT_REVISION" ]; then
    change_paths
    set -- $CHANGE_PATHS
    if [ -n "$(git -C "$BACKPACK_ROOT" status --porcelain --untracked-files=normal -- "$@")" ]; then
      warn 'This checkout has uncommitted changes that will be applied.'
    fi
  fi

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
      opencode)
        install_rtk
        ;;
    esac
  fi

  if [ "$REPLACE_EXISTING" -eq 1 ]; then
    warn '--replace is no longer needed; installs always replace Backpack-managed targets.'
  fi

  case "$INSTALL_TARGET" in
    ai|opencode|all)
      copy_dir_once "$BACKPACK_ROOT/engineering/adapters/opencode" "$CONFIG_DIR/opencode"
      ;;
  esac

  case "$INSTALL_TARGET" in
    ai|super|all)
      install_super_adapter
      ;;
  esac

  case "$INSTALL_TARGET" in
    opencode)
      link_entry "$BACKPACK_ROOT/engineering/portable/AGENTS.md" "$CONFIG_DIR/opencode/AGENTS.md"
      install_core_skills "$BACKPACK_AGENTS_DIR/skills"
      ;;
    codex)
      install_codex_adapter
      ;;
    claude)
      install_core_skills "$BACKPACK_AGENTS_DIR/skills"
      install_claude_adapter
      ;;
    ai|all)
      link_entry "$BACKPACK_ROOT/engineering/portable/AGENTS.md" "$CONFIG_DIR/opencode/AGENTS.md"
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

if [ "$LEGACY_COMPONENT" -eq 1 ]; then
  warn '`backpack install cockpit` is deprecated; use `backpack install engineering`.'
fi

if [ "$DIRECT_APPLY" -eq 0 ]; then
  if [ "$TARGET_SET" -eq 0 ]; then
    offer_gum_install
    ask_install_target
    printf '\n'
  fi
fi

CURRENT_REVISION=$(checkout_revision)
PREVIOUS_REVISION=$(read_installed_revision "$INSTALL_TARGET")

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
  verify_installation
  record_installation "$INSTALL_TARGET"
  record_installation_revision
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
  section 'Ready to install or refresh'
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
    verify_installation
    record_installation "$INSTALL_TARGET"
    record_installation_revision
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
