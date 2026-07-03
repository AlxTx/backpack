#!/usr/bin/env sh
set -eu

BACKPACK_ROOT=${BACKPACK_ROOT:-"$HOME/perso/backpack"}

fail() {
  printf '✗ %s\n' "$1" >&2
  exit 1
}

ok() {
  printf '✓ %s\n' "$1"
}

test -d "$BACKPACK_ROOT" || fail "missing backpack root: $BACKPACK_ROOT"
ok "backpack root exists"

test -f "$BACKPACK_ROOT/cockpit/opencode/opencode.json" || fail "missing cockpit/opencode/opencode.json"
ok "opencode config exists"

test -f "$BACKPACK_ROOT/memory/index.md" || fail "missing memory/index.md"
ok "memory index exists"

test -x "$BACKPACK_ROOT/tools/wakey/wakey" || fail "missing executable tools/wakey/wakey"
ok "wakey executable exists"

if test -f "$BACKPACK_ROOT/dotfiles/fish/fish_variables"; then
  fail "dotfiles/fish/fish_variables should not be versioned"
fi
ok "fish_variables absent"

if git -C "$BACKPACK_ROOT" remote -v | grep -q 'AlxTx/backpack'; then
  ok "git remote targets AlxTx/backpack"
else
  fail "git remote should target AlxTx/backpack"
fi
