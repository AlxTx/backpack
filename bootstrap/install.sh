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
APPLY=0
DIRECT_APPLY=0
PROFILE_MODE=personal
INSTALL_TARGET=opencode
TARGET_SET=0
REPLACE_EXISTING=0
UPDATE_EXISTING=0
WITH_RTK=1
SKILLS_SET=all
SKILLS_SET_SET=0
USAGE="Usage: $0 [--personal|--client] [--only ai|codex|claude|copilot|opencode|shell|editor|terminal|all] [--skills all|core|none] [--with-rtk|--without-rtk] [--replace] [--update] [--apply]"

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
        ai|codex|claude|copilot|opencode|shell|editor|terminal|all)
          INSTALL_TARGET=$1
          TARGET_SET=1
          ;;
        *)
          printf '%s\n' "$USAGE" >&2
          exit 2
          ;;
      esac
      ;;
    --skills)
      shift
      case "${1:-}" in
        all|core|none)
          SKILLS_SET=$1
          SKILLS_SET_SET=1
          ;;
        *)
          printf '%s\n' "$USAGE" >&2
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

gum_choose_target() {
  gum_header

  gum style --foreground 39 'Cockpit: portable engineering workflow and host adapters.'
  gum style --foreground 245 'Tools: shell, editor, and terminal configuration.'

  selection=$(gum choose \
    --header 'What do you want to install?' \
    --cursor '→ ' \
    --selected-prefix '✓ ' \
    --unselected-prefix '  ' \
    'Cockpit · OpenCode     Host adapter + shared workflow (default)' \
    'Cockpit · Codex        CLI + Desktop instructions and skills' \
    'Cockpit · Claude Code  CLI + Desktop rules, agents, and skills' \
    'Cockpit · Copilot      CLI instructions, skills, and App setup guide' \
    'Cockpit · AI stack     All four host adapters + RTK' \
    'Tools · Shell           Fish + Starship' \
    'Tools · Editor          Neovim' \
    'Tools · Terminal UI     Ghostty + Karabiner' \
    'Everything   All Backpack config' \
    'Quit') || {
      warn 'Install cancelled. No changes were made.'
      exit 0
    }

  case $selection in
    'Cockpit · OpenCode'*) INSTALL_TARGET=opencode ;;
    'Cockpit · Codex'*) INSTALL_TARGET=codex ;;
    'Cockpit · Claude'*) INSTALL_TARGET=claude ;;
    'Cockpit · Copilot'*) INSTALL_TARGET=copilot ;;
    'Cockpit · AI'*) INSTALL_TARGET=ai ;;
    'Tools · Shell'*) INSTALL_TARGET=shell ;;
    'Tools · Editor'*) INSTALL_TARGET=editor ;;
    'Tools · Terminal'*) INSTALL_TARGET=terminal ;;
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

What do you want to install?


Cockpit — portable workflow and host adapters

  1  OpenCode     CLI + Desktop adapter (default)
  2  Codex        CLI + Desktop instructions and skills
  3  Claude Code  CLI + Desktop rules, agents, and skills
  4  Copilot      CLI instructions, skills, and App setup guide
  5  AI stack     All four host adapters + RTK

Tools — machine and interface configuration

  6  Shell        Fish + Starship
  7  Editor       Neovim
  8  Terminal UI  Ghostty + Karabiner

Everything

  9  Everything   All Backpack config
  q  Quit

EOF

  choice_prompt 'Select an option (default: 1 OpenCode): '
  read choice

  case "${choice:-1}" in
    1) INSTALL_TARGET=opencode ;;
    2) INSTALL_TARGET=codex ;;
    3) INSTALL_TARGET=claude ;;
    4) INSTALL_TARGET=copilot ;;
    5) INSTALL_TARGET=ai ;;
    6) INSTALL_TARGET=shell ;;
    7) INSTALL_TARGET=editor ;;
    8) INSTALL_TARGET=terminal ;;
    9) INSTALL_TARGET=all ;;
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

gum_choose_skills() {
  gum style --foreground 39 \
    'Skill catalogue: one shared set for Codex, Claude Code, Copilot, and OpenCode.'

  skills_choice=$(gum choose \
    --header 'Which skills do you want to install?' \
    "All — personal doctrine + optional rule sets ($(count_skills all) skills)" \
    "Core only — personal doctrine ($(count_skills core) skills)" \
    'None — instructions and agents only') || return 1

  case "$skills_choice" in
    All*) SKILLS_SET=all ;;
    Core*) SKILLS_SET=core ;;
    None*) SKILLS_SET=none ;;
  esac
}

ask_skills_set() {
  target_uses_skills || return 0
  [ "$SKILLS_SET_SET" -eq 1 ] && return 0
  { [ -t 0 ] && [ -t 1 ]; } || return 0

  if use_gum; then
    gum_choose_skills
    return 0
  fi

  cat <<EOF

$(section 'Skills')
One shared catalogue, installed for whichever hosts you selected.

  1  All        personal doctrine + optional rule sets ($(count_skills all) skills)
  2  Core only  personal doctrine only ($(count_skills core) skills)
  3  None       instructions and agents only

Optional today ($(count_skills optional)): $(list_optional_skills)

EOF

  choice_prompt 'Select a skill set (default: 1 All): '
  read skills_choice

  case "${skills_choice:-1}" in
    1) SKILLS_SET=all ;;
    2) SKILLS_SET=core ;;
    3) SKILLS_SET=none ;;
    *)
      printf '✗ invalid choice: %s\n' "$skills_choice" >&2
      exit 2
      ;;
  esac
}

list_optional_skills() {
  optional_list=
  for optional_path in "$(skills_source_dir)"/*; do
    [ -d "$optional_path" ] || continue
    optional_name=$(basename "$optional_path")
    skill_is_optional "$optional_name" || continue
    if [ -z "$optional_list" ]; then
      optional_list=$optional_name
    else
      optional_list="$optional_list, $optional_name"
    fi
  done
  printf '%s' "${optional_list:-none}"
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

install_opencode_rtk_plugin() {
  source_path=$BACKPACK_ROOT/cockpit/adapters/opencode/plugins/rtk.ts
  target_path=$CONFIG_DIR/opencode/plugins/rtk.ts

  if [ ! -f "$source_path" ]; then
    printf '✗ missing OpenCode rtk plugin: %s\n' "$source_path" >&2
    exit 1
  fi

  if [ "$APPLY" -eq 0 ]; then
    info "install OpenCode rtk plugin at $target_path"
    return
  fi

  copy_path_replace "$source_path" "$target_path"
}

skills_source_dir() {
  printf '%s' "$BACKPACK_ROOT/cockpit/portable/skills"
}

skill_is_optional() {
  optional_candidate=$1
  optional_manifest="$BACKPACK_ROOT/cockpit/portable/skills.optional"

  [ -f "$optional_manifest" ] || return 1

  while IFS= read -r manifest_line || [ -n "$manifest_line" ]; do
    manifest_entry=${manifest_line%%#*}
    manifest_entry=$(printf '%s' "$manifest_entry" | tr -d ' \t')
    [ -n "$manifest_entry" ] || continue
    [ "$manifest_entry" = "$optional_candidate" ] && return 0
  done < "$optional_manifest"

  return 1
}

count_skills() {
  count_kind=$1
  count_total=0

  if [ "$count_kind" = none ]; then
    printf '0'
    return 0
  fi

  for count_path in "$(skills_source_dir)"/*; do
    [ -d "$count_path" ] || continue
    count_name=$(basename "$count_path")
    case "$count_kind" in
      optional) skill_is_optional "$count_name" || continue ;;
      core) skill_is_optional "$count_name" && continue ;;
    esac
    count_total=$((count_total + 1))
  done

  printf '%s' "$count_total"
}

target_uses_skills() {
  case "$INSTALL_TARGET" in
    ai|all|codex|claude|copilot|opencode) return 0 ;;
    *) return 1 ;;
  esac
}

# Link the selected skills one by one into a host catalogue. Per-skill links are
# what make the selection host-agnostic: the same set lands in ~/.agents/skills
# for Codex, Copilot, and OpenCode, and in ~/.claude/skills for Claude Code.
install_portable_skills() {
  skills_dest=$1
  skills_dir=$(skills_source_dir)

  if [ ! -d "$skills_dir" ]; then
    printf '✗ missing portable skills: %s\n' "$skills_dir" >&2
    exit 1
  fi

  if [ "$SKILLS_SET" = none ]; then
    info "skip skills for $skills_dest"
    return 0
  fi

  # Earlier Backpack releases linked the whole catalogue as one symlink. Writing
  # per-skill links through it would create entries inside the repository, so
  # replace it with a real directory first.
  if [ -L "$skills_dest" ]; then
    if [ "$APPLY" -eq 0 ]; then
      info "replace catalogue symlink $skills_dest with a directory"
    else
      mkdir -p "$backup_dir"
      backup_existing "$skills_dest"
    fi
  fi

  [ "$APPLY" -eq 1 ] && mkdir -p "$skills_dest"

  for skill_path in "$skills_dir"/*; do
    [ -d "$skill_path" ] || continue
    skill_name=$(basename "$skill_path")

    if [ "$SKILLS_SET" = core ] && skill_is_optional "$skill_name"; then
      info "skip optional skill $skill_name"
      continue
    fi

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
    info "link Claude rules, agents, and the $SKILLS_SET skill set into $BACKPACK_CLAUDE_DIR"
    return
  fi

  mkdir -p "$BACKPACK_CLAUDE_DIR/rules" "$BACKPACK_CLAUDE_DIR/agents"
  link_entry "$BACKPACK_ROOT/cockpit/portable/AGENTS.md" "$BACKPACK_CLAUDE_DIR/rules/backpack.md"

  install_portable_skills "$BACKPACK_CLAUDE_DIR/skills"

  for agent_path in "$source_root/agents"/*.md; do
    agent_name=$(basename "$agent_path")
    link_entry "$agent_path" "$BACKPACK_CLAUDE_DIR/agents/$agent_name"
  done
  success "Claude adapter linked at $BACKPACK_CLAUDE_DIR"
}

configure_rtk_claude() {
  if [ "$APPLY" -eq 0 ]; then
    info 'configure RTK Claude Code hook'
    return
  fi

  mkdir -p "$BACKPACK_CLAUDE_DIR"

  if rtk init -g --hook-only --auto-patch; then
    success 'RTK Claude Code hook configured'
  else
    warn 'could not configure the RTK Claude Code hook; shared rules remain active'
  fi
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

  # Keep machine-local extensions and dependencies that Backpack does not own.
  for entry in package.json package-lock.json node_modules .claude; do
    if [ -e "$LAST_BACKUP_PATH/$entry" ]; then
      cp -R "$LAST_BACKUP_PATH/$entry" "$target_root/$entry"
      success "kept $target_root/$entry"
    fi
  done

  for entry in agents prompts commands plugins themes README.md tui.json .gitignore; do
    if [ -e "$source_root/$entry" ]; then
      copy_path_replace "$source_root/$entry" "$target_root/$entry"
    fi
  done

  cat <<EOF

Kept local config:
  $target_root/opencode.json
  package.json / package-lock.json / node_modules / .claude (when present)

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
    printf '\nClient mode reminder:\n'

    case "$INSTALL_TARGET" in
      ai|opencode|all)
        printf '%s\n' \
          '- Backpack installs the OpenCode adapter and links the shared AI core.' \
          "- Edit $CONFIG_DIR/opencode/opencode.json locally for client LLM providers/models."
        ;;
    esac

    case "$INSTALL_TARGET" in
      ai|copilot|all)
        printf '%s\n' '- Copilot gets personal instructions locally; client repository instructions remain authoritative.'
        ;;
    esac

    printf '%s\n' '- Do not commit client providers, tokens, endpoints, or policies to Backpack.'
  fi
}

print_copilot_app_reminder() {
  case "$INSTALL_TARGET" in
    ai|copilot|all)
      cat <<EOF

GitHub Copilot App setup:
- Copilot CLI instructions and personal skills are installed automatically.
- The desktop app stores global instructions in its own settings and has no
  documented file-based configuration.
- After a successful install, Backpack prints the exact instruction block to paste.
EOF
      ;;
  esac
}

print_copilot_app_instructions() {
  case "$INSTALL_TARGET" in
    ai|copilot|all)
      cat <<EOF

GitHub Copilot App — one final step

Copy the complete block below, then paste it in:
  GitHub Copilot App → Settings → General → Global instructions

----- COPY FROM HERE -----
EOF
      "$SCRIPT_DIR/copilot-app-instructions.sh"
      cat <<EOF
----- COPY UNTIL HERE -----

EOF
      ;;
  esac
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
  Skills    $(if target_uses_skills; then printf '%s (%s of %s)' "$SKILLS_SET" "$(count_skills "$SKILLS_SET")" "$(count_skills all)"; else printf 'not applicable'; fi)
  Mode      $(if [ "$APPLY" -eq 1 ]; then printf 'apply'; else printf 'preview'; fi)

EOF

  if [ "$WITH_RTK" -eq 1 ]; then
    case "$INSTALL_TARGET" in
      ai|all)
        install_rtk
        install_opencode_rtk_plugin
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
        install_opencode_rtk_plugin
        ;;
    esac
  fi

  case "$INSTALL_TARGET" in
    ai)
      update_opencode_core "$BACKPACK_ROOT/cockpit/adapters/opencode" "$CONFIG_DIR/opencode"
      ;;
    opencode|all)
      if [ "$UPDATE_EXISTING" -eq 1 ]; then
        update_opencode_core "$BACKPACK_ROOT/cockpit/adapters/opencode" "$CONFIG_DIR/opencode"
      else
        copy_dir_once "$BACKPACK_ROOT/cockpit/adapters/opencode" "$CONFIG_DIR/opencode"
      fi
      ;;
  esac

  case "$INSTALL_TARGET" in
    opencode)
      link_entry "$BACKPACK_ROOT/cockpit/portable/AGENTS.md" "$CONFIG_DIR/opencode/AGENTS.md"
      install_portable_skills "$BACKPACK_AGENTS_DIR/skills"
      ;;
    codex)
      link_entry "$BACKPACK_ROOT/cockpit/portable/AGENTS.md" "$BACKPACK_CODEX_DIR/AGENTS.md"
      install_portable_skills "$BACKPACK_AGENTS_DIR/skills"
      ;;
    claude)
      install_portable_skills "$BACKPACK_AGENTS_DIR/skills"
      install_claude_adapter
      ;;
    copilot)
      link_entry "$BACKPACK_ROOT/cockpit/portable/AGENTS.md" "$BACKPACK_COPILOT_DIR/copilot-instructions.md"
      link_entry "$BACKPACK_ROOT/cockpit/portable/AGENTS.md" "$BACKPACK_COPILOT_DIR/instructions/backpack.instructions.md"
      install_portable_skills "$BACKPACK_AGENTS_DIR/skills"
      ;;
    ai|all)
      link_entry "$BACKPACK_ROOT/cockpit/portable/AGENTS.md" "$CONFIG_DIR/opencode/AGENTS.md"
      link_entry "$BACKPACK_ROOT/cockpit/portable/AGENTS.md" "$BACKPACK_CODEX_DIR/AGENTS.md"
      link_entry "$BACKPACK_ROOT/cockpit/portable/AGENTS.md" "$BACKPACK_COPILOT_DIR/copilot-instructions.md"
      link_entry "$BACKPACK_ROOT/cockpit/portable/AGENTS.md" "$BACKPACK_COPILOT_DIR/instructions/backpack.instructions.md"
      install_portable_skills "$BACKPACK_AGENTS_DIR/skills"
      install_claude_adapter
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
  print_copilot_app_reminder
}

if [ "$DIRECT_APPLY" -eq 0 ]; then
  if [ "$TARGET_SET" -eq 0 ]; then
    offer_gum_install
    ask_install_target
    printf '\n'
  fi
  ask_skills_set
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
  print_copilot_app_instructions
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
print_copilot_app_instructions
if [ -d "$backup_dir" ]; then
  printf 'Backups: %s\n' "$backup_dir"
fi
