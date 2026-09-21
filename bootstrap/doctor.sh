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
test -x "$BACKPACK_ROOT/bootstrap/check.sh" || fail "missing executable installation check"
test -x "$BACKPACK_ROOT/bootstrap/skills.sh" || fail "missing executable skill manager"
test -x "$BACKPACK_ROOT/tests/skills.test.sh" || fail "missing executable skill CLI test"
test -x "$BACKPACK_ROOT/tests/install.test.sh" || fail "missing executable interactive install test"
grep -q 'BACKPACK_BIN_DIR/backpack' "$BACKPACK_ROOT/bootstrap/install.sh" || fail "installer must expose the backpack command"
grep -q 'verify_installation' "$BACKPACK_ROOT/bootstrap/install.sh" || fail "installer must verify applied state"
ok "Backpack CLI exists"

if [ "$(uname -s)" = "Darwin" ]; then
  ok "macOS detected"
else
  fail "backpack currently targets macOS only"
fi

test -f "$BACKPACK_ROOT/engineering/adapters/opencode/opencode.json" || fail "missing OpenCode adapter config"
ok "opencode config exists"

test -f "$BACKPACK_ROOT/engineering/portable/AGENTS.md" || fail "missing engineering/portable/AGENTS.md"
ok "portable AGENTS.md exists"

grep -q '^applyTo: "\*\*"$' "$BACKPACK_ROOT/engineering/portable/AGENTS.md" || fail "portable AGENTS.md must retain its cross-host frontmatter"
ok "portable AGENTS.md frontmatter exists"

grep -q 'Plan → Build → Validate → Learn' "$BACKPACK_ROOT/engineering/portable/AGENTS.md" || fail "portable workflow must expose the canonical delivery loop"
grep -q '\[Backpack - <phase>\]' "$BACKPACK_ROOT/engineering/portable/AGENTS.md" || fail "portable workflow must expose Backpack activity"
grep -q 'reply yes once it is active' "$BACKPACK_ROOT/engineering/portable/AGENTS.md" || fail "portable workflow must make manual model switching explicit before confirmation"
grep -q 'Never commit, push' "$BACKPACK_ROOT/engineering/portable/AGENTS.md" || fail "portable workflow must protect Git delivery actions"
ok "canonical Backpack Engineering flow and Git gate exist"

for model in gpt-6-astra gpt-5.6-sol gpt-5.6-terra; do
  grep -q "$model" "$BACKPACK_ROOT/engineering/portable/MODELS.md" || fail "missing model routing for $model"
done
if grep -q 'gpt-5.6-luna' "$BACKPACK_ROOT/engineering/portable/MODELS.md"; then
  fail "Backpack Engineering model routing must stop at Terra unless a high-volume tier is justified"
fi
ok "Backpack Engineering uses the Astra, Sol, and Terra routing"

for adapter in codex claude opencode super; do
  test -d "$BACKPACK_ROOT/engineering/adapters/$adapter" || fail "missing $adapter adapter"
done
ok "all host adapter directories exist"

for adapter in codex claude opencode super; do
  test -f "$BACKPACK_ROOT/engineering/adapters/$adapter/README.md" || fail "missing $adapter adapter documentation"
done
ok "all host adapters are documented"

command -v jq >/dev/null 2>&1 || fail "jq is required for portable Super configuration"

for super_config in settings.json chat-defaults.json; do
  test -f "$BACKPACK_ROOT/engineering/adapters/super/$super_config" ||
    fail "missing Super adapter $super_config"
  jq -e . "$BACKPACK_ROOT/engineering/adapters/super/$super_config" >/dev/null ||
    fail "invalid Super adapter JSON: $super_config"
done
grep -q '"default_tool": "codex"' "$BACKPACK_ROOT/engineering/adapters/super/settings.json" ||
  fail "Super must use Codex as the portable default engine"
grep -A 2 '"experimental"' "$BACKPACK_ROOT/engineering/adapters/super/settings.json" | grep -q '"agent_orchestration": true' ||
  fail "Super adapter must enable agent orchestration"
grep -q 'sc team run' "$BACKPACK_ROOT/engineering/adapters/super/README.md" ||
  fail "Super adapter documentation must describe the current sc team workflow"
grep -q 'does not install.*superset-' "$BACKPACK_ROOT/engineering/adapters/super/README.md" ||
  fail "Super adapter documentation must exclude legacy Superset skill wrappers"
if grep -Eq '"(provider_profiles|enabled_providers|ai_routing|projects|workspaces|window_bounds|active_project_id|active_workspace_id|tools)"' \
  "$BACKPACK_ROOT/engineering/adapters/super/settings.json"; then
  fail "Super adapter contains machine-, provider-, or runtime-owned state"
fi
if grep -Eqi 'copilot|token|secret|credential' "$BACKPACK_ROOT/engineering/adapters/super/settings.json" \
  "$BACKPACK_ROOT/engineering/adapters/super/chat-defaults.json"; then
  fail "Super portable config contains client-owned or sensitive state"
fi
if grep -q '"model_id"' "$BACKPACK_ROOT/engineering/adapters/super/chat-defaults.json"; then
  fail "Super chat defaults must not pin model IDs"
fi
ok "Super adapter is portable and excludes runtime and client-owned state"

test ! -e "$BACKPACK_ROOT/engineering/adapters/copilot" ||
  fail "GitHub Copilot is client-owned and must not have a Backpack adapter"
ok "GitHub Copilot remains outside Backpack"

test ! -e "$BACKPACK_ROOT/cockpit" || fail "legacy cockpit directory still exists"
ok "Backpack Engineering uses the canonical engineering directory"

for agent in backpack-code-review backpack-product-qa; do
  test -f "$BACKPACK_ROOT/engineering/adapters/codex/agents/$agent.toml" ||
    fail "missing Codex $agent agent"
  grep -q '^sandbox_mode = "read-only"$' "$BACKPACK_ROOT/engineering/adapters/codex/agents/$agent.toml" ||
    fail "Codex $agent agent must be read-only"
done
ok "Codex validation agents exist and are read-only"

test -d "$BACKPACK_ROOT/engineering/adapters/claude/agents" || fail "missing Claude adapter agents"
for agent in plan build review qa design; do
  test -f "$BACKPACK_ROOT/engineering/adapters/claude/agents/$agent.md" || fail "missing Claude $agent agent"
done
for agent in plan review qa design; do
  grep -q '^permissionMode: plan$' "$BACKPACK_ROOT/engineering/adapters/claude/agents/$agent.md" ||
    fail "Claude $agent agent must use native plan permissions"
done
for duplicate in validate learn backpack-pattern-scan; do
  test ! -e "$BACKPACK_ROOT/engineering/adapters/claude/agents/$duplicate.md" ||
    fail "Claude must use the portable $duplicate capability instead of a duplicate agent"
done
if grep -Rq '^model:' "$BACKPACK_ROOT/engineering/adapters/claude/agents"; then
  fail "Claude agents must inherit the user-selected model"
fi
ok "Claude exposes one surface per Backpack Engineering capability"

test -f "$BACKPACK_ROOT/engineering/adapters/opencode/agents/product-design.md" || fail "missing OpenCode product-design agent"
ok "product-design agent exists"

test -f "$BACKPACK_ROOT/engineering/adapters/opencode/commands/backpack-design.md" || fail "missing OpenCode backpack-design command"
ok "backpack-design command exists"

test -f "$BACKPACK_ROOT/engineering/adapters/opencode/commands/backpack-brainstorm.md" || fail "missing OpenCode backpack-brainstorm command"
grep -q '^agent: plan$' "$BACKPACK_ROOT/engineering/adapters/opencode/commands/backpack-brainstorm.md" ||
  fail "OpenCode backpack-brainstorm command must use the read-only plan agent"
ok "backpack-brainstorm command uses plan"

grep -A 2 '^agent: product-design$' "$BACKPACK_ROOT/engineering/adapters/opencode/commands/backpack-design.md" | grep -q '^subtask: true$' ||
  fail "OpenCode backpack-design command must delegate an isolated product-design subtask"

test -f "$BACKPACK_ROOT/engineering/portable/skills/backpack-enhance-prompt/SKILL.md" || fail "missing portable backpack-enhance-prompt skill"
ok "safe prompt refinement capability exists"

for prompt in plan build review; do
  grep -q 'global `AGENTS.md`' "$BACKPACK_ROOT/engineering/adapters/opencode/prompts/$prompt.md" ||
    fail "OpenCode $prompt prompt must delegate shared doctrine to global AGENTS.md"
done
grep -q '"default_agent": "build"' "$BACKPACK_ROOT/engineering/adapters/opencode/opencode.json" ||
  fail "OpenCode build must be the default primary agent"
grep -A 14 '"plan": {' "$BACKPACK_ROOT/engineering/adapters/opencode/opencode.json" | grep -q '"bash": "deny"' ||
  fail "OpenCode plan must hard-deny shell so auto-approve remains read-only"
grep -A 14 '"plan": {' "$BACKPACK_ROOT/engineering/adapters/opencode/opencode.json" | grep -q '"edit": "deny"' ||
  fail "OpenCode plan must hard-deny edits in read-only mode"
grep -A 14 '"build": {' "$BACKPACK_ROOT/engineering/adapters/opencode/opencode.json" | grep -q '"bash": "ask"' ||
  fail "OpenCode build shell must require approval"
grep -A 16 '"review": {' "$BACKPACK_ROOT/engineering/adapters/opencode/opencode.json" | grep -q '"bash": "deny"' ||
  fail "OpenCode review must hard-deny shell in strict read-only mode"
grep -A 16 '"review": {' "$BACKPACK_ROOT/engineering/adapters/opencode/opencode.json" | grep -q '"edit": "deny"' ||
  fail "OpenCode review must hard-deny edits in strict read-only mode"
grep -q '^  bash: deny$' "$BACKPACK_ROOT/engineering/adapters/opencode/agents/qa.md" ||
  fail "OpenCode Product QA must hard-deny shell in strict read-only mode"
grep -q '^  edit: deny$' "$BACKPACK_ROOT/engineering/adapters/opencode/agents/qa.md" ||
  fail "OpenCode Product QA must hard-deny edits in strict read-only mode"
if grep -R 'capture.sh' "$BACKPACK_ROOT/engineering/adapters/opencode/opencode.json" "$BACKPACK_ROOT/engineering/adapters/opencode/prompts/plan.md" "$BACKPACK_ROOT/engineering/adapters/opencode/prompts/review.md" >/dev/null 2>&1; then
  fail "OpenCode read-only agents must not retain a backpack-pattern-capture shell exception"
fi
if grep -q '"interactive": {' "$BACKPACK_ROOT/engineering/adapters/opencode/opencode.json" ||
   grep -q '"design": {' "$BACKPACK_ROOT/engineering/adapters/opencode/opencode.json"; then
  fail "OpenCode must expose only build and plan as custom primary agents"
fi
if grep -Eq '"(model|small_model)"[[:space:]]*:' "$BACKPACK_ROOT/engineering/adapters/opencode/opencode.json" ||
   grep -REq '^(model|variant):' "$BACKPACK_ROOT/engineering/adapters/opencode/agents"; then
  fail "OpenCode agents must inherit the current session model and provider"
fi
test "$(grep -c '"backpack-\*": "allow"' "$BACKPACK_ROOT/engineering/adapters/opencode/opencode.json")" -ge 2 ||
  fail "OpenCode must allow trusted Backpack Engineering skills globally and from build"
grep -A 6 '"general": {' "$BACKPACK_ROOT/engineering/adapters/opencode/opencode.json" | grep -q '"description":' ||
  fail "OpenCode general subagent needs a delegation description"
grep -A 6 '"explore": {' "$BACKPACK_ROOT/engineering/adapters/opencode/opencode.json" | grep -q '"description":' ||
  fail "OpenCode explore subagent needs a delegation description"
ok "OpenCode prompts stay thin around portable doctrine"

test -f "$BACKPACK_ROOT/engineering/adapters/opencode/agents/qa.md" || fail "missing OpenCode qa agent"
for command in backpack-brainstorm backpack-design backpack-review backpack-qa; do
  test -f "$BACKPACK_ROOT/engineering/adapters/opencode/commands/$command.md" ||
    fail "missing OpenCode /$command command"
done
for command_path in "$BACKPACK_ROOT/engineering/adapters/opencode/commands"/*.md; do
  command_name=$(basename "$command_path")
  case "$command_name" in
    backpack-brainstorm.md|backpack-design.md|backpack-review.md|backpack-qa.md) ;;
    *) fail "unexpected or unnamespaced OpenCode command: $command_name" ;;
  esac
done
for duplicate in brainstorm design review qa validate learn start-work backpack-pattern-scan backpack-enhance-prompt backpack-pattern-capture; do
  test ! -e "$BACKPACK_ROOT/engineering/adapters/opencode/commands/$duplicate.md" ||
    fail "OpenCode retained retired or unnamespaced command /$duplicate"
done
for duplicate in validate learn; do
  test ! -e "$BACKPACK_ROOT/engineering/adapters/opencode/agents/$duplicate.md" ||
    fail "OpenCode $duplicate agent duplicates a portable skill"
done
ok "OpenCode commands are namespaced and expose one surface per Backpack Engineering capability"

for skill in brand-messaging website-content-architecture website-copywriting; do
  test -f "$BACKPACK_ROOT/engineering/portable/skills/$skill/SKILL.md" || fail "missing portable $skill skill"
done
ok "content design skills exist"

for retired_skill in code-first-product-design frontend-design design-quality-standards style-refined-product style-editorial-saas style-bento-dashboard style-developer-minimal style-friendly-consumer; do
  test ! -e "$BACKPACK_ROOT/engineering/portable/skills/$retired_skill" || fail "retired UX/UI skill still exists: $retired_skill"
done
ok "Impeccable has no competing Backpack UX/UI skills"

for skill in backpack-enhance-prompt backpack-pattern-scan backpack-pattern-capture backpack-validate backpack-learn backpack-start-work; do
  test -f "$BACKPACK_ROOT/engineering/portable/skills/$skill/SKILL.md" || fail "missing portable $skill skill"
  grep -q 'In GitHub Copilot, do not use this skill' "$BACKPACK_ROOT/engineering/portable/skills/$skill/SKILL.md" ||
    fail "$skill must remain disabled in GitHub Copilot"
done
test -x "$BACKPACK_ROOT/engineering/portable/skills/backpack-pattern-capture/scripts/capture.sh" || fail "portable pattern capture script is not executable"
ok "portable workflow and pattern skills are the canonical user surfaces"

for skill in vercel-react-best-practices vercel-composition-patterns; do
  test -f "$BACKPACK_ROOT/engineering/portable/skills/$skill/SKILL.md" || fail "missing vendored $skill skill"
  test -d "$BACKPACK_ROOT/engineering/portable/skills/$skill/rules" || fail "missing rules directory for $skill"
done
ok "vendored Vercel skills exist"

core_manifest="$BACKPACK_ROOT/engineering/portable/skills.core"
test -f "$core_manifest" || fail "missing engineering/portable/skills.core"
while IFS= read -r manifest_line || [ -n "$manifest_line" ]; do
  manifest_entry=${manifest_line%%#*}
  manifest_entry=$(printf '%s' "$manifest_entry" | tr -d ' \t')
  [ -n "$manifest_entry" ] || continue
  test -d "$BACKPACK_ROOT/engineering/portable/skills/$manifest_entry" ||
    fail "skills.core lists a skill that does not exist: $manifest_entry"
done < "$core_manifest"
ok "Backpack Engineering core manifest resolves"

skill_catalog="$BACKPACK_ROOT/engineering/portable/skills.tsv"
test -f "$skill_catalog" || fail "missing engineering/portable/skills.tsv"
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
      test -f "$BACKPACK_ROOT/engineering/portable/skills/$local_skill/SKILL.md" ||
        fail "catalog entry $skill_id references missing local skill: $local_skill"
      ;;
    github:*) test -n "${skill_source#github:}" || fail "catalog entry $skill_id has an empty GitHub source" ;;
    *) fail "catalog entry $skill_id has unsupported source: $skill_source" ;;
  esac
done < "$skill_catalog"
ok "curated skill catalog resolves"

for skill_dir in "$BACKPACK_ROOT/engineering/portable/skills"/*; do
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
