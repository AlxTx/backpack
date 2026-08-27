#!/usr/bin/env sh
set -eu

TEST_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd -P)
BACKPACK_ROOT=$(CDPATH= cd "$TEST_DIR/.." && pwd -P)
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/backpack-install-test.XXXXXX")
trap 'rm -rf "$TEST_ROOT"' EXIT HUP INT TERM

TEST_HOME="$TEST_ROOT/home"
mkdir -p "$TEST_HOME"

output=$(printf '5\ny\n' | \
  HOME="$TEST_HOME" \
  CONFIG_DIR="$TEST_HOME/.config" \
  BACKPACK_AGENTS_DIR="$TEST_HOME/.agents" \
  CODEX_HOME="$TEST_HOME/.codex" \
  CLAUDE_CONFIG_DIR="$TEST_HOME/.claude" \
  COPILOT_HOME="$TEST_HOME/.copilot" \
  BACKPACK_BIN_DIR="$TEST_HOME/.local/bin" \
  BACKPACK_ROOT="$BACKPACK_ROOT" \
  "$BACKPACK_ROOT/bootstrap/install.sh" cockpit --without-rtk)

printf '%s' "$output" | grep -q 'Cockpit installed for all supported tools' || {
  printf '✗ interactive Cockpit install did not complete\n' >&2
  exit 1
}

test -L "$TEST_HOME/.local/bin/backpack" || {
  printf '✗ interactive Cockpit install did not link the Backpack command\n' >&2
  exit 1
}

test -L "$TEST_HOME/.config/opencode/AGENTS.md" || {
  printf '✗ OpenCode install did not link the portable doctrine\n' >&2
  exit 1
}

for codex_agent in cockpit-code-review cockpit-product-qa; do
  test -L "$TEST_HOME/.codex/agents/$codex_agent.toml" || {
    printf '✗ Codex install did not link the %s agent\n' "$codex_agent" >&2
    exit 1
  }
done

for cockpit_skill in cockpit-validate cockpit-learn cockpit-start-work; do
  test -L "$TEST_HOME/.agents/skills/$cockpit_skill" || {
    printf '✗ Cockpit install did not link the %s core skill\n' "$cockpit_skill" >&2
    exit 1
  }
done

grep -q '"shell": "/opt/homebrew/bin/fish"' "$TEST_HOME/.config/opencode/opencode.json" || {
  printf '✗ OpenCode install did not configure Fish explicitly\n' >&2
  exit 1
}

grep -q '^Status: READY TO BUILD | DECISION NEEDED | DEPENDENCY PENDING$' "$TEST_HOME/.config/opencode/prompts/plan.md" || {
  printf '✗ OpenCode plan prompt does not lead with a delivery status\n' >&2
  exit 1
}

grep -q 'maximum 7 execution steps' "$TEST_HOME/.config/opencode/prompts/plan.md" || {
  printf '✗ OpenCode plan prompt does not enforce compact progressive disclosure\n' >&2
  exit 1
}

grep -q '^agent: plan$' "$TEST_HOME/.config/opencode/commands/brainstorm.md" || {
  printf '✗ OpenCode brainstorm command is not pinned to plan\n' >&2
  exit 1
}

grep -q '^agent: product-design$' "$TEST_HOME/.config/opencode/commands/design.md" || {
  printf '✗ OpenCode design command does not delegate to product-design\n' >&2
  exit 1
}

grep -A 2 '^agent: product-design$' "$TEST_HOME/.config/opencode/commands/design.md" | grep -q '^subtask: true$' || {
  printf '✗ OpenCode design command is not isolated as a subtask\n' >&2
  exit 1
}

if grep -Eq '"(model|small_model)"[[:space:]]*:' "$TEST_HOME/.config/opencode/opencode.json" ||
   grep -REq '^(model|variant):' "$TEST_HOME/.config/opencode/agents"; then
  printf '✗ OpenCode adapter pins a provider instead of inheriting the session model\n' >&2
  exit 1
fi

for duplicate in validate learn start-work pattern-scan refine capture; do
  if [ -e "$TEST_HOME/.config/opencode/commands/$duplicate.md" ]; then
    printf '✗ OpenCode command /%s duplicates a portable skill\n' "$duplicate" >&2
    exit 1
  fi
done

for duplicate in validate learn; do
  if [ -e "$TEST_HOME/.config/opencode/agents/$duplicate.md" ]; then
    printf '✗ OpenCode agent %s duplicates a portable skill\n' "$duplicate" >&2
    exit 1
  fi
done

printf '{"local-only": true}\n' > "$TEST_HOME/.config/opencode/opencode.json"
printf 'local extension\n' > "$TEST_HOME/.config/opencode/local-only.txt"

replace_output=$( \
  HOME="$TEST_HOME" \
  CONFIG_DIR="$TEST_HOME/.config" \
  BACKPACK_AGENTS_DIR="$TEST_HOME/.agents" \
  CODEX_HOME="$TEST_HOME/.codex" \
  CLAUDE_CONFIG_DIR="$TEST_HOME/.claude" \
  COPILOT_HOME="$TEST_HOME/.copilot" \
  BACKPACK_BIN_DIR="$TEST_HOME/.local/bin" \
  BACKPACK_ROOT="$BACKPACK_ROOT" \
  "$BACKPACK_ROOT/bootstrap/install.sh" cockpit --opencode --without-rtk)

cmp "$BACKPACK_ROOT/cockpit/adapters/opencode/opencode.json" "$TEST_HOME/.config/opencode/opencode.json" || {
  printf '✗ OpenCode reinstall did not replace the local opencode.json\n' >&2
  exit 1
}

test ! -e "$TEST_HOME/.config/opencode/local-only.txt" || {
  printf '✗ OpenCode reinstall preserved a local-only adapter file\n' >&2
  exit 1
}

backup_config=$(find "$TEST_HOME" -path '*/.config.backup.*/home/.config/opencode/opencode.json' -print -quit)
test -n "$backup_config" && grep -q '"local-only": true' "$backup_config" || {
  printf '✗ OpenCode reinstall did not retain the previous adapter in its backup\n' >&2
  exit 1
}

printf '%s' "$replace_output" | grep -q '^Backups: ' || {
  printf '✗ OpenCode reinstall did not report the recovery backup\n' >&2
  exit 1
}

GENERAL_HOME="$TEST_ROOT/general-home"
mkdir -p \
  "$GENERAL_HOME/.config/opencode" \
  "$GENERAL_HOME/.codex" \
  "$GENERAL_HOME/.codex/agents" \
  "$GENERAL_HOME/.claude/rules" \
  "$GENERAL_HOME/.claude/agents" \
  "$GENERAL_HOME/.copilot/instructions" \
  "$GENERAL_HOME/.agents/skills/prompt-refinement" \
  "$GENERAL_HOME/.config/fish" \
  "$GENERAL_HOME/.config/nvim" \
  "$GENERAL_HOME/.config/ghostty"

printf '{"local-only": true}\n' > "$GENERAL_HOME/.config/opencode/opencode.json"
printf 'local codex\n' > "$GENERAL_HOME/.codex/AGENTS.md"
printf 'local codex agent\n' > "$GENERAL_HOME/.codex/agents/local.toml"
printf 'model = "personal-model"\n' > "$GENERAL_HOME/.codex/config.toml"
printf 'local claude rule\n' > "$GENERAL_HOME/.claude/rules/backpack.md"
printf 'local claude agent\n' > "$GENERAL_HOME/.claude/agents/local.md"
printf 'local copilot\n' > "$GENERAL_HOME/.copilot/copilot-instructions.md"
printf 'legacy copilot\n' > "$GENERAL_HOME/.copilot/instructions/backpack.instructions.md"
printf 'local skill\n' > "$GENERAL_HOME/.agents/skills/prompt-refinement/SKILL.md"
printf 'local fish\n' > "$GENERAL_HOME/.config/fish/local.fish"
printf 'local nvim\n' > "$GENERAL_HOME/.config/nvim/local.lua"
printf 'local ghostty\n' > "$GENERAL_HOME/.config/ghostty/local.conf"

everything_output=$( \
  HOME="$GENERAL_HOME" \
  CONFIG_DIR="$GENERAL_HOME/.config" \
  BACKPACK_AGENTS_DIR="$GENERAL_HOME/.agents" \
  CODEX_HOME="$GENERAL_HOME/.codex" \
  CLAUDE_CONFIG_DIR="$GENERAL_HOME/.claude" \
  COPILOT_HOME="$GENERAL_HOME/.copilot" \
  BACKPACK_BIN_DIR="$GENERAL_HOME/.local/bin" \
  BACKPACK_ROOT="$BACKPACK_ROOT" \
  "$BACKPACK_ROOT/bootstrap/install.sh" everything --personal --without-rtk)

cmp "$BACKPACK_ROOT/cockpit/adapters/opencode/opencode.json" "$GENERAL_HOME/.config/opencode/opencode.json" || {
  printf '✗ Everything install did not replace OpenCode\n' >&2
  exit 1
}

for managed_link in \
  "$GENERAL_HOME/.codex/AGENTS.md" \
  "$GENERAL_HOME/.codex/agents/cockpit-code-review.toml" \
  "$GENERAL_HOME/.codex/agents/cockpit-product-qa.toml" \
  "$GENERAL_HOME/.claude/rules/backpack.md" \
  "$GENERAL_HOME/.claude/agents" \
  "$GENERAL_HOME/.copilot/copilot-instructions.md" \
  "$GENERAL_HOME/.agents/skills/prompt-refinement" \
  "$GENERAL_HOME/.config/fish" \
  "$GENERAL_HOME/.config/nvim" \
  "$GENERAL_HOME/.config/ghostty"; do
  test -L "$managed_link" || {
    printf '✗ Everything install did not replace managed path: %s\n' "$managed_link" >&2
    exit 1
  }
done

test -f "$GENERAL_HOME/.codex/agents/local.toml" || {
  printf '✗ Everything install removed a non-Backpack Codex agent\n' >&2
  exit 1
}

grep -q '^model = "personal-model"$' "$GENERAL_HOME/.codex/config.toml" || {
  printf '✗ Everything install changed personal Codex configuration\n' >&2
  exit 1
}

grep -Fq 'test "$PWD" = "$HOME"' "$GENERAL_HOME/.config/fish/config.fish" || {
  printf '✗ Fish config does not preserve an inherited project directory\n' >&2
  exit 1
}

test ! -e "$GENERAL_HOME/.copilot/instructions/backpack.instructions.md" || {
  printf '✗ Everything install preserved legacy Copilot instructions\n' >&2
  exit 1
}

general_backup=$(printf '%s\n' "$everything_output" | sed -n 's/^Backups: //p' | tail -n 1)
test -n "$general_backup" || {
  printf '✗ Everything install did not report the recovery backup\n' >&2
  exit 1
}

for backup_marker in \
  "$general_backup$GENERAL_HOME/.codex/AGENTS.md" \
  "$general_backup$GENERAL_HOME/.claude/agents/local.md" \
  "$general_backup$GENERAL_HOME/.copilot/copilot-instructions.md" \
  "$general_backup$GENERAL_HOME/.agents/skills/prompt-refinement/SKILL.md" \
  "$general_backup$GENERAL_HOME/.config/fish/local.fish"; do
  test -f "$backup_marker" || {
    printf '✗ Everything install did not back up managed path: %s\n' "$backup_marker" >&2
    exit 1
  }
done

printf '✓ interactive Cockpit install contract\n'
