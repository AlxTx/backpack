#!/usr/bin/env sh
set -eu

SCRIPT_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd -P)
DEFAULT_BACKPACK_ROOT=$(CDPATH= cd "$SCRIPT_DIR/.." && pwd -P)
BACKPACK_ROOT=${BACKPACK_ROOT:-"$DEFAULT_BACKPACK_ROOT"}
QUIET=${BACKPACK_DOCTOR_QUIET:-0}

if [ ! -d "$BACKPACK_ROOT" ]; then
  if [ "$QUIET" -eq 0 ]; then
    printf 'i ignoring stale BACKPACK_ROOT: %s\n' "$BACKPACK_ROOT"
  fi
  BACKPACK_ROOT=$DEFAULT_BACKPACK_ROOT
fi

fail() {
  printf '✗ %s\n' "$1" >&2
  exit 1
}

ok() {
  if [ "$QUIET" -eq 0 ]; then
    printf '✓ %s\n' "$1"
  fi
}

test -d "$BACKPACK_ROOT" || fail "missing backpack root: $BACKPACK_ROOT"
ok "backpack root exists"

case "$BACKPACK_ROOT" in
  */Dev/perso/backpack)
    if [ "$QUIET" -eq 0 ]; then
      printf 'i path casing: repo is under ~/Dev/perso/backpack; docs use ~/dev/perso/backpack as canonical, both are tolerated on macOS\n'
    fi
    ;;
esac

if [ "$(uname -s)" = "Darwin" ]; then
  ok "macOS detected"
else
  fail "backpack currently targets macOS only"
fi

test -f "$BACKPACK_ROOT/cockpit/opencode/opencode.json" || fail "missing cockpit/opencode/opencode.json"
ok "opencode config exists"

test -f "$BACKPACK_ROOT/cockpit/opencode/agents/product-design.md" || fail "missing cockpit/opencode/agents/product-design.md"
ok "product-design agent exists"

test -f "$BACKPACK_ROOT/cockpit/opencode/commands/design.md" || fail "missing cockpit/opencode/commands/design.md"
ok "design command exists"

test -f "$BACKPACK_ROOT/cockpit/opencode/skills/code-first-product-design/SKILL.md" || fail "missing cockpit/opencode/skills/code-first-product-design/SKILL.md"
ok "code-first product design skill exists"

test -f "$BACKPACK_ROOT/cockpit/opencode/skills/frontend-design/SKILL.md" || fail "missing cockpit/opencode/skills/frontend-design/SKILL.md"
ok "frontend design skill exists"

test -f "$BACKPACK_ROOT/cockpit/opencode/skills/design-quality-standards/SKILL.md" || fail "missing cockpit/opencode/skills/design-quality-standards/SKILL.md"
ok "design quality standards skill exists"

for skill in style-refined-product style-editorial-saas style-bento-dashboard style-developer-minimal style-friendly-consumer; do
  test -f "$BACKPACK_ROOT/cockpit/opencode/skills/$skill/SKILL.md" || fail "missing cockpit/opencode/skills/$skill/SKILL.md"
done
ok "design style pack skills exist"

test -f "$BACKPACK_ROOT/memory/index.md" || fail "missing memory/index.md"
ok "memory index exists"

test -x "$BACKPACK_ROOT/tools/wakey/wakey" || fail "missing executable tools/wakey/wakey"
ok "wakey executable exists"

if git -C "$BACKPACK_ROOT" ls-files --error-unmatch dotfiles/fish/fish_variables >/dev/null 2>&1; then
  fail "dotfiles/fish/fish_variables should not be versioned"
fi
ok "fish_variables is not tracked"

if git -C "$BACKPACK_ROOT" remote -v | grep -q 'AlxTx/backpack'; then
  ok "git remote targets AlxTx/backpack"
else
  fail "git remote should target AlxTx/backpack"
fi
