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

grep -q 'portable `pattern-scan` skill' "$TEST_HOME/.config/opencode/prompts/pattern-scan.md" || {
  printf '✗ OpenCode pattern-scan did not delegate to the portable skill\n' >&2
  exit 1
}

grep -q 'portable `pattern-scan` skill is the' "$TEST_HOME/.config/opencode/prompts/pattern-radar.md" || {
  printf '✗ OpenCode Pattern Radar adapter does not defer to the portable scan contract\n' >&2
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

grep -A 2 '^agent: pattern-scan$' "$TEST_HOME/.config/opencode/commands/pattern-scan.md" | grep -q '^subtask: true$' || {
  printf '✗ OpenCode pattern-scan command is not isolated as a subtask\n' >&2
  exit 1
}

grep -q '^model: openai/gpt-5.6-sol$' "$TEST_HOME/.config/opencode/agents/product-design.md" || {
  printf '✗ OpenCode product-design model routing is not explicit\n' >&2
  exit 1
}

printf '✓ interactive Cockpit install contract\n'
