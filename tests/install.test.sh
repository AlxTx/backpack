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

printf '✓ interactive Cockpit install contract\n'
