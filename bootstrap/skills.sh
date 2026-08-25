#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd -P)
DEFAULT_BACKPACK_ROOT=$(CDPATH= cd "$SCRIPT_DIR/.." && pwd -P)
BACKPACK_ROOT=${BACKPACK_ROOT:-"$DEFAULT_BACKPACK_ROOT"}
CATALOG="$BACKPACK_ROOT/cockpit/portable/skills.tsv"

usage() {
  cat <<'EOF'
Usage:
  backpack skills
  backpack list
  backpack find <need>
  backpack info <skill>
  backpack add <skill>
  backpack remove <skill>

Skills are installed in the current project. Backpack selects an installed
skill automatically when its description matches the task.
EOF
}

use_gum() {
  [ -t 0 ] && [ -t 1 ] && command -v gum >/dev/null 2>&1
}

fail() {
  printf '✗ %s\n' "$1" >&2
  exit 1
}

project_root() {
  if command -v git >/dev/null 2>&1 && git_root=$(git rev-parse --show-toplevel 2>/dev/null); then
    printf '%s' "$git_root"
  else
    pwd -P
  fi
}

catalog_entry() {
  catalog_id=$1
  awk -F '|' -v id="$catalog_id" '
    function collapse(value, result, previous, i, character) {
      for (i=1; i<=length(value); i++) {
        character=substr(value, i, 1)
        if (character != previous) result=result character
        previous=character
      }
      return result
    }
    $0 !~ /^#/ && ($1 == id || collapse($1) == collapse(id)) { print; exit }
  ' "$CATALOG"
}

load_entry() {
  entry=$(catalog_entry "$1")
  [ -n "$entry" ] || fail "unknown skill: $1 (try: backpack skills)"
  IFS='|' read -r SKILL_ID SKILL_CATEGORY SKILL_SOURCE SKILL_NAME SKILL_SUMMARY SKILL_WHEN SKILL_BOUNDARY <<EOF
$entry
EOF
}

skill_directories() {
  cat <<'EOF'
.agents/skills|Codex/OpenCode
.claude/skills|Claude Code
.cursor/skills|Cursor
.github/skills|GitHub Copilot
.gemini/skills|Gemini
.opencode/skills|OpenCode
EOF
}

is_installed() {
  wanted_skill=$1
  root=$2
  while IFS='|' read -r relative_dir provider; do
    [ -n "$relative_dir" ] || continue
    [ -f "$root/$relative_dir/$wanted_skill/SKILL.md" ] && return 0
  done <<EOF
$(skill_directories)
EOF
  return 1
}

list_skills() {
  render_skills ''
}

find_skills() {
  render_skills "$1"
}

render_skills() {
  query=$1
  root=$(project_root)
  query_lower=$(printf '%s' "$query" | tr '[:upper:]' '[:lower:]')
  resolved_id=
  if [ -n "$query" ]; then
    resolved_entry=$(catalog_entry "$query")
    [ -z "$resolved_entry" ] || resolved_id=${resolved_entry%%|*}
  fi

  printf 'Curated skills\n%s\n' "$root"
  [ -z "$query" ] || printf 'Matching: %s\n' "$query"
  printf '\n'

  found=0
  while IFS='|' read -r catalog_id category source skill summary when boundary; do
    [ -n "$catalog_id" ] || continue
    case "$catalog_id" in \#*) continue ;; esac

    if [ -n "$query_lower" ]; then
      haystack_lower=$(printf '%s' "$catalog_id $category $summary $when" | tr '[:upper:]' '[:lower:]')
      case "$haystack_lower" in
        *"$query_lower"*) ;;
        *) [ "$catalog_id" = "$resolved_id" ] || continue ;;
      esac
    fi

    if is_installed "$skill" "$root"; then
      status=installed
    else
      status=available
    fi
    printf '  %-30s %-13s %-18s %s\n' "$catalog_id" "[$status]" "[$category]" "$summary"
    found=1
  done < "$CATALOG"

  if [ "$found" -eq 0 ]; then
    printf '  No curated skill matches this need. Run backpack list to see all skills.\n'
  fi
  printf '\nInspect: backpack info <skill>\nAdd:     backpack add <skill>\n'
}

show_info() {
  [ "$#" -eq 1 ] || { usage >&2; exit 2; }
  load_entry "$1"
  root=$(project_root)
  if is_installed "$SKILL_NAME" "$root"; then
    status=installed
  else
    status='not installed'
  fi

  case "$SKILL_SOURCE" in
    local:*) source_display="Backpack (${SKILL_SOURCE#local:})" ;;
    github:*) source_display="GitHub (${SKILL_SOURCE#github:})" ;;
  esac

  cat <<EOF
$SKILL_ID

Category:  $SKILL_CATEGORY
Status:    $status in $root
Purpose:   $SKILL_SUMMARY
Use when:  $SKILL_WHEN
Boundary:  $SKILL_BOUNDARY
Source:    $source_display
Skill:     $SKILL_NAME
EOF
}

require_npx() {
  command -v npx >/dev/null 2>&1 || fail 'npx is required to manage project skills'
}

add_skill() {
  [ "$#" -eq 1 ] || { usage >&2; exit 2; }
  load_entry "$1"
  require_npx
  root=$(project_root)

  case "$SKILL_SOURCE" in
    local:*) package="$BACKPACK_ROOT/cockpit/portable/skills/${SKILL_SOURCE#local:}" ;;
    github:*) package=${SKILL_SOURCE#github:} ;;
    *) fail "unsupported source for $SKILL_ID: $SKILL_SOURCE" ;;
  esac

  printf 'Adding %s to %s\n' "$SKILL_ID" "$root"
  cd "$root"
  exec npx --yes skills add "$package" --skill "$SKILL_NAME" --yes
}

remove_skill() {
  [ "$#" -eq 1 ] || { usage >&2; exit 2; }
  load_entry "$1"
  require_npx
  root=$(project_root)

  printf 'Removing %s from %s\n' "$SKILL_ID" "$root"
  cd "$root"
  exec npx --yes skills remove "$SKILL_NAME" --yes
}

catalog_choices() {
  awk -F '|' '$0 !~ /^#/ { printf "%s | [%s] %s\n", $1, $2, $5 }' "$CATALOG"
}

need_choices() {
  awk -F '|' '$0 !~ /^#/ { printf "%s | [%s] %s\n", $1, $2, $6 }' "$CATALOG"
}

installed_choices() {
  root=$(project_root)
  while IFS='|' read -r catalog_id category source skill summary when boundary; do
    [ -n "$catalog_id" ] || continue
    case "$catalog_id" in \#*) continue ;; esac
    if is_installed "$skill" "$root"; then
      printf '%s | [%s] %s\n' "$catalog_id" "$category" "$summary"
    fi
  done < "$CATALOG"
}

choose_skill() {
  prompt=$1
  choices=$2
  SELECTED_SKILL=

  [ -n "$choices" ] || return 1

  if use_gum; then
    selection=$(printf '%s\n' "$choices" | gum choose --header "$prompt" --cursor '→ ') || return 1
    SELECTED_SKILL=${selection%% *}
    return 0
  fi

  choice_file=$(mktemp "${TMPDIR:-/tmp}/backpack-skill-choice.XXXXXX") || fail 'cannot create temporary choice list'
  printf '%s\n' "$choices" > "$choice_file"
  printf '\n%s\n\n' "$prompt"
  awk '{ printf "  %d  %s\n", NR, $0 }' "$choice_file"
  printf '\n? Select an option (q to cancel): '
  read choice
  case "$choice" in
    q|Q|'') rm -f "$choice_file"; return 1 ;;
    *[!0-9]*) rm -f "$choice_file"; return 1 ;;
  esac
  selection=$(sed -n "${choice}p" "$choice_file")
  rm -f "$choice_file"
  [ -n "$selection" ] || return 1
  SELECTED_SKILL=${selection%% *}
}

pause_menu() {
  if use_gum; then
    gum input --placeholder 'Press Enter to continue' >/dev/null || true
  else
    printf '\nPress Enter to continue… '
    read ignored
  fi
}

dispatch_menu_choice() {
  case "$1" in
    find)
      choices=$(need_choices)
      choose_skill 'What do you need?' "$choices" || return 0
      show_info "$SELECTED_SKILL"
      pause_menu
      ;;
    add)
      choices=$(catalog_choices)
      choose_skill 'Which skill do you want to add?' "$choices" || return 0
      add_skill "$SELECTED_SKILL"
      ;;
    remove)
      choices=$(installed_choices)
      if [ -z "$choices" ]; then
        printf '\nNo curated project skill is installed.\n'
        pause_menu
        return 0
      fi
      choose_skill 'Which skill do you want to remove?' "$choices" || return 0
      remove_skill "$SELECTED_SKILL"
      ;;
    back) return 1 ;;
  esac
}

gum_skill_menu() {
  selection=$(gum choose \
    --header 'Project skills' \
    --cursor '→ ' \
    'Explore all needs' \
    'Add a skill' \
    'Remove a skill' \
    'Back') || return 1

  case "$selection" in
    'Explore all needs') dispatch_menu_choice find ;;
    'Add a skill') dispatch_menu_choice add ;;
    'Remove a skill') dispatch_menu_choice remove ;;
    'Back') return 1 ;;
  esac
}

numbered_skill_menu() {
  cat <<'EOF'

◆ Project skills

  1  Explore all needs
  2  Add a skill
  3  Remove a skill
  b  Back

EOF
  printf '? Select an option: '
  read choice
  case "$choice" in
    1) dispatch_menu_choice find ;;
    2) dispatch_menu_choice add ;;
    3) dispatch_menu_choice remove ;;
    b|B|q|Q) return 1 ;;
    *) printf '✗ invalid choice: %s\n' "$choice" >&2 ;;
  esac
}

skill_menu() {
  while :; do
    if use_gum; then
      gum_skill_menu || return 0
    else
      numbered_skill_menu || return 0
    fi
  done
}

[ -f "$CATALOG" ] || fail "missing skill catalog: $CATALOG"

case "${1:-}" in
  menu|skills)
    shift
    [ "$#" -eq 0 ] || { usage >&2; exit 2; }
    skill_menu
    ;;
  list)
    shift
    [ "$#" -eq 0 ] || { usage >&2; exit 2; }
    list_skills
    ;;
  find)
    shift
    [ "$#" -eq 1 ] || { usage >&2; exit 2; }
    find_skills "$1"
    ;;
  info)
    shift
    show_info "$@"
    ;;
  add)
    shift
    add_skill "$@"
    ;;
  remove)
    shift
    remove_skill "$@"
    ;;
  help|-h|--help) usage ;;
  *) usage >&2; exit 2 ;;
esac
