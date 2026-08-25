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

info() {
  if [ "$QUIET" -eq 0 ]; then
    printf 'i %s\n' "$1"
  fi
}

test -d "$BACKPACK_ROOT" || fail "missing backpack root: $BACKPACK_ROOT"
ok "backpack root exists"

test -x "$BACKPACK_ROOT/backpack" || fail "missing executable backpack command"
test -x "$BACKPACK_ROOT/bootstrap/status.sh" || fail "missing executable status command"
test -x "$BACKPACK_ROOT/bootstrap/skills.sh" || fail "missing executable skill manager"
test -x "$BACKPACK_ROOT/tests/skills.test.sh" || fail "missing executable skill CLI test"
test -x "$BACKPACK_ROOT/tests/install.test.sh" || fail "missing executable interactive install test"
grep -q 'BACKPACK_BIN_DIR/backpack' "$BACKPACK_ROOT/bootstrap/install.sh" || fail "installer must expose the backpack command"
ok "Backpack CLI exists"

if [ "$(uname -s)" = "Darwin" ]; then
  ok "macOS detected"
else
  fail "backpack currently targets macOS only"
fi

test -f "$BACKPACK_ROOT/cockpit/adapters/opencode/opencode.json" || fail "missing OpenCode adapter config"
ok "opencode config exists"

test -f "$BACKPACK_ROOT/cockpit/portable/AGENTS.md" || fail "missing cockpit/portable/AGENTS.md"
ok "portable AGENTS.md exists"

grep -q '^applyTo: "\*\*"$' "$BACKPACK_ROOT/cockpit/portable/AGENTS.md" || fail "portable AGENTS.md must apply to all files when loaded by Copilot"
ok "portable AGENTS.md is compatible with Copilot personal instructions"

grep -q 'Plan → Build → Validate → Learn' "$BACKPACK_ROOT/cockpit/portable/AGENTS.md" || fail "portable workflow must expose the canonical delivery loop"
grep -q 'Cockpit › <phase>' "$BACKPACK_ROOT/cockpit/portable/AGENTS.md" || fail "portable workflow must expose Cockpit activity"
grep -q 'Never commit, push' "$BACKPACK_ROOT/cockpit/portable/AGENTS.md" || fail "portable workflow must protect Git delivery actions"
ok "canonical Cockpit flow and Git gate exist"

for adapter in codex claude copilot opencode; do
  test -d "$BACKPACK_ROOT/cockpit/adapters/$adapter" || fail "missing $adapter adapter"
done
ok "all host adapter directories exist"

for adapter in codex claude copilot opencode; do
  test -f "$BACKPACK_ROOT/cockpit/adapters/$adapter/README.md" || fail "missing $adapter adapter documentation"
done
ok "all host adapters are documented"

test -d "$BACKPACK_ROOT/cockpit/adapters/claude/agents" || fail "missing Claude adapter agents"
for agent in plan build review qa validate learn design pattern-scan; do
  test -f "$BACKPACK_ROOT/cockpit/adapters/claude/agents/$agent.md" || fail "missing Claude $agent agent"
done
ok "Claude adapter agents exist"

test -f "$BACKPACK_ROOT/cockpit/adapters/opencode/agents/product-design.md" || fail "missing OpenCode product-design agent"
ok "product-design agent exists"

test -f "$BACKPACK_ROOT/cockpit/adapters/opencode/commands/design.md" || fail "missing OpenCode design command"
ok "design command exists"

test -f "$BACKPACK_ROOT/cockpit/adapters/opencode/commands/refine.md" || fail "missing OpenCode refine command"
test -f "$BACKPACK_ROOT/cockpit/portable/skills/prompt-refinement/SKILL.md" || fail "missing portable prompt-refinement skill"
ok "safe prompt refinement capability exists"

test -f "$BACKPACK_ROOT/cockpit/adapters/opencode/prompts/product-design.md" || fail "missing OpenCode design primary prompt"
ok "design primary prompt exists"

for capability in qa validate learn; do
  test -f "$BACKPACK_ROOT/cockpit/adapters/opencode/agents/$capability.md" || fail "missing OpenCode $capability agent"
  test -f "$BACKPACK_ROOT/cockpit/adapters/opencode/commands/$capability.md" || fail "missing OpenCode /$capability command"
done
ok "OpenCode validate and learn capabilities exist"

for skill in brand-messaging website-content-architecture website-copywriting; do
  test -f "$BACKPACK_ROOT/cockpit/portable/skills/$skill/SKILL.md" || fail "missing portable $skill skill"
done
ok "content design skills exist"

for retired_skill in code-first-product-design frontend-design design-quality-standards style-refined-product style-editorial-saas style-bento-dashboard style-developer-minimal style-friendly-consumer; do
  test ! -e "$BACKPACK_ROOT/cockpit/portable/skills/$retired_skill" || fail "retired UX/UI skill still exists: $retired_skill"
done
ok "Impeccable has no competing Backpack UX/UI skills"

for skill in pattern-scan pattern-capture; do
  test -f "$BACKPACK_ROOT/cockpit/portable/skills/$skill/SKILL.md" || fail "missing portable $skill skill"
done
test -x "$BACKPACK_ROOT/cockpit/portable/skills/pattern-capture/scripts/capture.sh" || fail "portable pattern capture script is not executable"
ok "pattern learning skills exist"

for skill in vercel-react-best-practices vercel-composition-patterns; do
  test -f "$BACKPACK_ROOT/cockpit/portable/skills/$skill/SKILL.md" || fail "missing vendored $skill skill"
  test -d "$BACKPACK_ROOT/cockpit/portable/skills/$skill/rules" || fail "missing rules directory for $skill"
done
ok "vendored Vercel skills exist"

core_manifest="$BACKPACK_ROOT/cockpit/portable/skills.core"
test -f "$core_manifest" || fail "missing cockpit/portable/skills.core"
while IFS= read -r manifest_line || [ -n "$manifest_line" ]; do
  manifest_entry=${manifest_line%%#*}
  manifest_entry=$(printf '%s' "$manifest_entry" | tr -d ' \t')
  [ -n "$manifest_entry" ] || continue
  test -d "$BACKPACK_ROOT/cockpit/portable/skills/$manifest_entry" ||
    fail "skills.core lists a skill that does not exist: $manifest_entry"
done < "$core_manifest"
ok "Cockpit core manifest resolves"

skill_catalog="$BACKPACK_ROOT/cockpit/portable/skills.tsv"
test -f "$skill_catalog" || fail "missing cockpit/portable/skills.tsv"
awk -F '|' '
  $0 !~ /^#/ && NF != 7 { exit 1 }
  $0 !~ /^#/ && seen[$1]++ { exit 1 }
' "$skill_catalog" || fail "skill catalog must contain unique seven-field entries"
grep -q '^impeccable|ux-ui|github:pbakaus/impeccable|impeccable|' "$skill_catalog" || fail "Impeccable must be the curated UX/UI skill"
while IFS='|' read -r skill_id skill_category skill_source skill_name skill_summary skill_when skill_boundary; do
  case "$skill_id" in ''|\#*) continue ;; esac
  case "$skill_source" in
    local:*)
      local_skill=${skill_source#local:}
      test -f "$BACKPACK_ROOT/cockpit/portable/skills/$local_skill/SKILL.md" ||
        fail "catalog entry $skill_id references missing local skill: $local_skill"
      ;;
    github:*) test -n "${skill_source#github:}" || fail "catalog entry $skill_id has an empty GitHub source" ;;
    *) fail "catalog entry $skill_id has unsupported source: $skill_source" ;;
  esac
done < "$skill_catalog"
ok "curated skill catalog resolves"

for skill_dir in "$BACKPACK_ROOT/cockpit/portable/skills"/*; do
  test -d "$skill_dir" || continue
  skill_name=$(basename "$skill_dir")
  test -f "$skill_dir/SKILL.md" || fail "missing SKILL.md for $skill_name"
  frontmatter_name=$(awk '/^name:/{print $2; exit}' "$skill_dir/SKILL.md")
  [ "$frontmatter_name" = "$skill_name" ] ||
    fail "skill $skill_name declares name: $frontmatter_name; hosts resolve skills by directory name"
done
ok "skill frontmatter names match their directories"

test -f "$BACKPACK_ROOT/memory/index.md" || fail "missing memory/index.md"
ok "memory index exists"

test -x "$BACKPACK_ROOT/tools/wakey/wakey" || fail "missing executable tools/wakey/wakey"
ok "wakey executable exists"

if command -v rtk >/dev/null 2>&1; then
  ok "rtk token-efficient shell proxy available"
else
  info "rtk is not installed; AI hosts will fall back to native shell commands"
fi

if git -C "$BACKPACK_ROOT" ls-files --error-unmatch dotfiles/fish/fish_variables >/dev/null 2>&1; then
  fail "dotfiles/fish/fish_variables should not be versioned"
fi
ok "fish_variables is not tracked"

if git -C "$BACKPACK_ROOT" remote -v | grep -q 'AlxTx/backpack'; then
  ok "git remote targets AlxTx/backpack"
else
  fail "git remote should target AlxTx/backpack"
fi
