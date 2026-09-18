#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd -P)
DEFAULT_BACKPACK_ROOT=$(CDPATH= cd "$SCRIPT_DIR/.." && pwd -P)
BACKPACK_ROOT=${BACKPACK_ROOT:-"$DEFAULT_BACKPACK_ROOT"}
CONFIG_DIR=${CONFIG_DIR:-"$HOME/.config"}
BACKPACK_AGENTS_DIR=${BACKPACK_AGENTS_DIR:-"$HOME/.agents"}
BACKPACK_CODEX_DIR=${CODEX_HOME:-"$HOME/.codex"}
BACKPACK_CLAUDE_DIR=${CLAUDE_CONFIG_DIR:-"$HOME/.claude"}
if [ "${SUPER_CONFIG_DIR+x}" = x ]; then
  BACKPACK_SUPER_DIR=$SUPER_CONFIG_DIR
elif [ -e "$HOME/.super.engineering" ] || [ -L "$HOME/.super.engineering" ]; then
  BACKPACK_SUPER_DIR=$HOME/.super.engineering
else
  BACKPACK_SUPER_DIR=$HOME/.superconductor
fi
BACKPACK_BIN_DIR=${BACKPACK_BIN_DIR:-"$HOME/.local/bin"}
BACKPACK_STATE_FILE=${BACKPACK_STATE_FILE:-"$CONFIG_DIR/backpack/installed-components"}

FAILURES=0
CHECKED=0
WANT_CLI=0
WANT_OPENCODE=0
WANT_CODEX=0
WANT_CLAUDE=0
WANT_SUPER=0
WANT_SHELL=0
WANT_EDITOR=0
WANT_TERMINAL=0

pass() {
  CHECKED=$((CHECKED + 1))
  printf '  ✓ %s\n' "$1"
}

fail() {
  CHECKED=$((CHECKED + 1))
  FAILURES=$((FAILURES + 1))
  printf '  ✗ %s — %s\n' "$1" "$2" >&2
}

skip() {
  printf '  · %s — not managed on this Mac\n' "$1"
}

expect_link() {
  label=$1
  target_path=$2
  source_path=$3

  if [ ! -L "$target_path" ]; then
    if [ -e "$target_path" ]; then
      fail "$label" "expected a Backpack symlink at $target_path"
    else
      fail "$label" "missing $target_path"
    fi
    return
  fi

  actual_target=$(readlink "$target_path")
  if [ "$actual_target" != "$source_path" ]; then
    fail "$label" "points to $actual_target instead of $source_path"
  elif [ ! -e "$target_path" ]; then
    fail "$label" "broken symlink"
  else
    pass "$label"
  fi
}

expect_file() {
  label=$1
  target_path=$2
  source_path=$3

  if [ ! -f "$target_path" ]; then
    fail "$label" "missing $target_path"
  elif ! cmp -s "$source_path" "$target_path"; then
    fail "$label" "content differs from Backpack"
  else
    pass "$label"
  fi
}

expect_source_tree() {
  label=$1
  source_dir=$2
  target_dir=$3
  tree_ok=1
  manifest=$(mktemp "${TMPDIR:-/tmp}/backpack-check.XXXXXX")
  find "$source_dir" -type f -print > "$manifest"

  while IFS= read -r source_file; do
    relative_path=${source_file#"$source_dir"/}
    target_file=$target_dir/$relative_path
    if [ ! -f "$target_file" ] || ! cmp -s "$source_file" "$target_file"; then
      tree_ok=0
      break
    fi
  done < "$manifest"
  rm -f "$manifest"

  if [ "$tree_ok" -eq 1 ]; then
    pass "$label"
  else
    fail "$label" "missing or stale adapter file: $relative_path"
  fi
}

expect_exact_directory() {
  label=$1
  source_dir=$2
  target_dir=$3
  if [ ! -d "$target_dir" ]; then
    fail "$label" "missing $target_dir"
    return
  fi
  source_manifest=$(mktemp "${TMPDIR:-/tmp}/backpack-source.XXXXXX")
  target_manifest=$(mktemp "${TMPDIR:-/tmp}/backpack-target.XXXXXX")

  write_entry_manifest "$source_dir" "$source_manifest"
  write_entry_manifest "$target_dir" "$target_manifest"

  if cmp -s "$source_manifest" "$target_manifest"; then
    pass "$label"
  else
    fail "$label" "unexpected or missing managed file"
  fi
  rm -f "$source_manifest" "$target_manifest"
}

write_entry_manifest() {
  directory=$1
  output_path=$2
  (
    CDPATH= cd "$directory"
    find . \( -type f -o -type l \) -print | sort | while IFS= read -r entry_path; do
      if [ -L "$entry_path" ]; then
        printf 'link %s -> %s\n' "$entry_path" "$(readlink "$entry_path")"
      else
        printf 'file %s\n' "$entry_path"
      fi
    done
  ) > "$output_path"
}

expect_json_superset() {
  label=$1
  target_path=$2
  source_path=$3

  if [ ! -f "$target_path" ]; then
    fail "$label" "missing $target_path"
  elif ! jq -e . "$target_path" >/dev/null 2>&1; then
    fail "$label" "invalid JSON in $target_path"
  elif ! jq -e -s '.[0] * .[1] == .[0]' "$target_path" "$source_path" >/dev/null; then
    fail "$label" "portable values differ from Backpack"
  else
    pass "$label"
  fi
}

enable_target() {
  case "$1" in
    opencode)
      WANT_CLI=1
      WANT_OPENCODE=1
      ;;
    codex)
      WANT_CLI=1
      WANT_CODEX=1
      ;;
    claude)
      WANT_CLI=1
      WANT_CLAUDE=1
      ;;
    super)
      WANT_CLI=1
      WANT_SUPER=1
      ;;
    ai|engineering)
      WANT_CLI=1
      WANT_OPENCODE=1
      WANT_CODEX=1
      WANT_CLAUDE=1
      WANT_SUPER=1
      ;;
    shell)
      WANT_CLI=1
      WANT_SHELL=1
      ;;
    editor)
      WANT_CLI=1
      WANT_EDITOR=1
      ;;
    terminal)
      WANT_CLI=1
      WANT_TERMINAL=1
      ;;
    machine)
      WANT_CLI=1
      WANT_SHELL=1
      WANT_EDITOR=1
      WANT_TERMINAL=1
      ;;
    all|everything)
      WANT_CLI=1
      WANT_OPENCODE=1
      WANT_CODEX=1
      WANT_CLAUDE=1
      WANT_SUPER=1
      WANT_SHELL=1
      WANT_EDITOR=1
      WANT_TERMINAL=1
      ;;
    '') ;;
    *)
      printf 'Usage: backpack check [engineering|opencode|codex|claude|super|machine|everything]\n' >&2
      exit 2
      ;;
  esac
}

load_recorded_targets() {
  if [ -f "$BACKPACK_STATE_FILE" ]; then
    while IFS= read -r recorded_target || [ -n "$recorded_target" ]; do
      enable_target "$recorded_target"
    done < "$BACKPACK_STATE_FILE"
  fi

  # Discover components installed before the state manifest was introduced.
  # Recorded components remain authoritative when a managed path later disappears.
  if [ -e "$CONFIG_DIR/opencode/AGENTS.md" ] || [ -L "$CONFIG_DIR/opencode/AGENTS.md" ]; then enable_target opencode; fi
  if [ -e "$BACKPACK_CODEX_DIR/AGENTS.md" ] || [ -L "$BACKPACK_CODEX_DIR/AGENTS.md" ]; then enable_target codex; fi
  if [ -e "$BACKPACK_CLAUDE_DIR/rules/backpack.md" ] || [ -L "$BACKPACK_CLAUDE_DIR/rules/backpack.md" ]; then enable_target claude; fi
  if [ -e "$BACKPACK_SUPER_DIR/settings.json" ]; then enable_target super; fi
  if [ -e "$CONFIG_DIR/fish" ] || [ -L "$CONFIG_DIR/fish" ]; then enable_target shell; fi
  if [ -e "$CONFIG_DIR/nvim" ] || [ -L "$CONFIG_DIR/nvim" ]; then enable_target editor; fi
  if [ -e "$CONFIG_DIR/ghostty" ] || [ -L "$CONFIG_DIR/ghostty" ]; then enable_target terminal; fi
  if [ -e "$BACKPACK_BIN_DIR/backpack" ] || [ -L "$BACKPACK_BIN_DIR/backpack" ]; then WANT_CLI=1; fi
}

check_core_skills() {
  skills_dest=$1
  destination_label=$2
  while IFS= read -r skill_name || [ -n "$skill_name" ]; do
    case "$skill_name" in ''|'#'*) continue ;; esac
    expect_link "$destination_label/$skill_name" \
      "$skills_dest/$skill_name" \
      "$BACKPACK_ROOT/engineering/portable/skills/$skill_name"
  done < "$BACKPACK_ROOT/engineering/portable/skills.core"
}

check_opencode() {
  expect_link 'OpenCode rules' "$CONFIG_DIR/opencode/AGENTS.md" "$BACKPACK_ROOT/engineering/portable/AGENTS.md"
  expect_source_tree 'OpenCode adapter' "$BACKPACK_ROOT/engineering/adapters/opencode" "$CONFIG_DIR/opencode"
  expect_exact_directory 'OpenCode commands' "$BACKPACK_ROOT/engineering/adapters/opencode/commands" "$CONFIG_DIR/opencode/commands"
  expect_exact_directory 'OpenCode agents' "$BACKPACK_ROOT/engineering/adapters/opencode/agents" "$CONFIG_DIR/opencode/agents"
  expect_exact_directory 'OpenCode prompts' "$BACKPACK_ROOT/engineering/adapters/opencode/prompts" "$CONFIG_DIR/opencode/prompts"
}

check_codex() {
  expect_link 'Codex rules' "$BACKPACK_CODEX_DIR/AGENTS.md" "$BACKPACK_ROOT/engineering/portable/AGENTS.md"
  for agent_name in backpack-code-review backpack-product-qa; do
    expect_link "Codex agent $agent_name" \
      "$BACKPACK_CODEX_DIR/agents/$agent_name.toml" \
      "$BACKPACK_ROOT/engineering/adapters/codex/agents/$agent_name.toml"
  done
}

check_claude() {
  expect_link 'Claude rules' "$BACKPACK_CLAUDE_DIR/rules/backpack.md" "$BACKPACK_ROOT/engineering/portable/AGENTS.md"
  expect_link 'Claude agents' "$BACKPACK_CLAUDE_DIR/agents" "$BACKPACK_ROOT/engineering/adapters/claude/agents"
  check_core_skills "$BACKPACK_CLAUDE_DIR/skills" 'Claude skills'
}

check_super() {
  command -v jq >/dev/null 2>&1 || {
    fail 'Super config' 'jq is required to validate merged JSON'
    return
  }
  expect_json_superset 'Super settings' "$BACKPACK_SUPER_DIR/settings.json" "$BACKPACK_ROOT/engineering/adapters/super/settings.json"
  expect_json_superset 'Super chat defaults' "$BACKPACK_SUPER_DIR/chat-defaults.json" "$BACKPACK_ROOT/engineering/adapters/super/chat-defaults.json"

  if [ "${SUPER_CONFIG_DIR+x}" != x ]; then
    old_super_dir=$HOME/.superconductor
    new_super_dir=$HOME/.super.engineering
    if [ -e "$old_super_dir" ] && [ ! -e "$new_super_dir" ] && [ ! -L "$new_super_dir" ]; then
      fail 'Super data alias' 'run `sc migrate-data` to publish ~/.super.engineering without moving existing data'
    elif [ -e "$old_super_dir" ] && [ -L "$new_super_dir" ]; then
      old_super_real=$(CDPATH= cd "$old_super_dir" && pwd -P)
      new_super_real=$(CDPATH= cd "$new_super_dir" && pwd -P)
      if [ "$new_super_real" = "$old_super_real" ]; then
        pass 'Super data alias'
      else
        fail 'Super data alias' 'the new folder does not resolve to the existing storage'
      fi
    elif [ -e "$old_super_dir" ] && [ -e "$new_super_dir" ] && [ ! -L "$new_super_dir" ]; then
      fail 'Super data alias' 'old and new storage are independent; preserve both and resolve with `sc migrate-data`'
    elif [ -e "$new_super_dir" ]; then
      pass 'Super canonical storage'
    fi
  fi
}

check_shell() {
  expect_link 'Fish' "$CONFIG_DIR/fish" "$BACKPACK_ROOT/dotfiles/fish"
  expect_link 'Starship' "$CONFIG_DIR/starship.toml" "$BACKPACK_ROOT/dotfiles/starship/starship.toml"
  expect_link 'Starship Catppuccin' "$CONFIG_DIR/starship-catppuccin.toml" "$BACKPACK_ROOT/dotfiles/starship/starship-catppuccin.toml"
  expect_link 'Starship Dragon' "$CONFIG_DIR/starship-dragon.toml" "$BACKPACK_ROOT/dotfiles/starship/starship-dragon.toml"
  expect_link 'Starship Tokyo' "$CONFIG_DIR/starship-tokyo.toml" "$BACKPACK_ROOT/dotfiles/starship/starship-tokyo.toml"
}

check_editor() {
  expect_link 'Neovim' "$CONFIG_DIR/nvim" "$BACKPACK_ROOT/dotfiles/nvim"
}

check_terminal() {
  expect_link 'Karabiner' "$CONFIG_DIR/karabiner" "$BACKPACK_ROOT/dotfiles/karabiner"
  expect_link 'Ghostty' "$CONFIG_DIR/ghostty" "$BACKPACK_ROOT/dotfiles/ghostty"
}

requested_target=${1:-}
if [ -n "$requested_target" ]; then
  enable_target "$requested_target"
else
  load_recorded_targets
fi

printf '◆ Backpack installation check\n\n'

if [ "$WANT_CLI" -eq 1 ]; then
  expect_link 'Backpack command' "$BACKPACK_BIN_DIR/backpack" "$BACKPACK_ROOT/backpack"
else
  skip 'Backpack command'
fi

if [ "$WANT_OPENCODE" -eq 1 ]; then check_opencode; else skip 'OpenCode'; fi
if [ "$WANT_CODEX" -eq 1 ]; then check_codex; else skip 'Codex'; fi
if [ "$WANT_CLAUDE" -eq 1 ]; then check_claude; else skip 'Claude Code'; fi
if [ "$WANT_OPENCODE" -eq 1 ] || [ "$WANT_CODEX" -eq 1 ] || [ "$WANT_CLAUDE" -eq 1 ]; then
  check_core_skills "$BACKPACK_AGENTS_DIR/skills" 'shared skills'
fi
if [ "$WANT_SUPER" -eq 1 ]; then check_super; else skip 'Super config'; fi
if [ "$WANT_SHELL" -eq 1 ]; then check_shell; else skip 'Shell configuration'; fi
if [ "$WANT_EDITOR" -eq 1 ]; then check_editor; else skip 'Editor configuration'; fi
if [ "$WANT_TERMINAL" -eq 1 ]; then check_terminal; else skip 'Terminal configuration'; fi

printf '\n'
if [ "$FAILURES" -gt 0 ]; then
  printf '✗ installation drift detected: %s failure(s)\n' "$FAILURES" >&2
  exit 1
fi

if [ "$CHECKED" -eq 0 ]; then
  printf '✗ no Backpack installation was detected\n' >&2
  exit 1
fi

printf '✓ installation matches Backpack\n'
