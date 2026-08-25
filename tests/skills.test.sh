#!/usr/bin/env sh
set -eu

TEST_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd -P)
BACKPACK_ROOT=$(CDPATH= cd "$TEST_DIR/.." && pwd -P)
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/backpack-skills-test.XXXXXX")
trap 'rm -rf "$TEST_ROOT"' EXIT HUP INT TERM

fail() {
  printf '✗ %s\n' "$1" >&2
  exit 1
}

PROJECT_ROOT="$TEST_ROOT/project"
FAKE_BIN="$TEST_ROOT/bin"
CALL_LOG="$TEST_ROOT/npx.args"
mkdir -p "$PROJECT_ROOT/.agents/skills/example" "$FAKE_BIN"

cat > "$PROJECT_ROOT/.agents/skills/example/SKILL.md" <<'EOF'
---
name: example
description: Test skill.
---
EOF

cat > "$FAKE_BIN/npx" <<'EOF'
#!/usr/bin/env sh
printf '%s\n' "$@" > "$BP_TEST_CALL_LOG"
EOF
chmod +x "$FAKE_BIN/npx"

find_output=$(cd "$PROJECT_ROOT" && BACKPACK_ROOT="$BACKPACK_ROOT" "$BACKPACK_ROOT/backpack" find design)
printf '%s' "$find_output" | grep -q 'impeccable' || fail 'backpack find design must return Impeccable'

typo_output=$(cd "$PROJECT_ROOT" && BACKPACK_ROOT="$BACKPACK_ROOT" "$BACKPACK_ROOT/backpack" info impecable)
printf '%s' "$typo_output" | grep -q '^impeccable$' || fail 'a common Impeccable spelling variant must resolve to the canonical skill'

info_output=$(cd "$PROJECT_ROOT" && BACKPACK_ROOT="$BACKPACK_ROOT" "$BACKPACK_ROOT/backpack" info impeccable)
printf '%s' "$info_output" | grep -q 'Category:  ux-ui' || fail 'backpack info must expose the skill category'
printf '%s' "$info_output" | grep -q 'not installed' || fail 'backpack info must expose project installation state'

list_output=$(cd "$PROJECT_ROOT" && BACKPACK_ROOT="$BACKPACK_ROOT" "$BACKPACK_ROOT/backpack" list)
printf '%s' "$list_output" | grep -q 'impeccable.*\[available\]' || fail 'backpack list must show installable curated skills'
printf '%s' "$list_output" | grep -q 'composition-patterns.*\[available\]' || fail 'backpack list must be exhaustive'

menu_output=$(cd "$PROJECT_ROOT" && printf 'b\n' | BACKPACK_ROOT="$BACKPACK_ROOT" "$BACKPACK_ROOT/bootstrap/skills.sh" menu)
printf '%s' "$menu_output" | grep -q 'Explore all needs' || fail 'the interactive skill menu must expose exhaustive need discovery'
printf '%s' "$menu_output" | grep -q 'Add a skill' || fail 'the interactive skill menu must expose skill installation'
printf '%s' "$menu_output" | grep -q 'List installed skills' && fail 'the interactive skill menu must not duplicate the status catalogue'

needs_output=$(cd "$PROJECT_ROOT" && printf '1\nq\nb\n' | BACKPACK_ROOT="$BACKPACK_ROOT" "$BACKPACK_ROOT/bootstrap/skills.sh" menu)
printf '%s' "$needs_output" | grep -q 'defines, changes, audits, or polishes a user interface' || fail 'need discovery must include UX/UI work'
printf '%s' "$needs_output" | grep -q 'component APIs are growing complex or boolean-heavy' || fail 'need discovery must include every curated skill'

mkdir -p "$PROJECT_ROOT/.agents/skills/vercel-react-best-practices"
cat > "$PROJECT_ROOT/.agents/skills/vercel-react-best-practices/SKILL.md" <<'EOF'
---
name: vercel-react-best-practices
description: Test curated alias.
---
EOF
list_output=$(cd "$PROJECT_ROOT" && BACKPACK_ROOT="$BACKPACK_ROOT" "$BACKPACK_ROOT/backpack" list)
printf '%s' "$list_output" | grep -q 'react-best-practices.*\[installed\]' || fail 'backpack list must show installed status for a curated skill'
printf '%s' "$list_output" | grep -q 'vercel-react-best-practices' && fail 'backpack list must hide the underlying implementation name behind its curated id'

(
  cd "$PROJECT_ROOT"
  PATH="$FAKE_BIN:$PATH" BP_TEST_CALL_LOG="$CALL_LOG" BACKPACK_ROOT="$BACKPACK_ROOT" \
    "$BACKPACK_ROOT/backpack" add impeccable
)
expected_add='--yes
skills
add
pbakaus/impeccable
--skill
impeccable
--yes'
[ "$(cat "$CALL_LOG")" = "$expected_add" ] || fail 'backpack add must delegate the curated source and skill to the Skills CLI'

(
  cd "$PROJECT_ROOT"
  PATH="$FAKE_BIN:$PATH" BP_TEST_CALL_LOG="$CALL_LOG" BACKPACK_ROOT="$BACKPACK_ROOT" \
    "$BACKPACK_ROOT/backpack" remove impeccable
)
expected_remove='--yes
skills
remove
impeccable
--yes'
[ "$(cat "$CALL_LOG")" = "$expected_remove" ] || fail 'backpack remove must remove the curated skill from project scope'

printf '✓ skill CLI contract\n'
