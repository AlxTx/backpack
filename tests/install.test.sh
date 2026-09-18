#!/usr/bin/env sh
set -eu

TEST_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd -P)
BACKPACK_ROOT=$(CDPATH= cd "$TEST_DIR/.." && pwd -P)
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/backpack-install-test.XXXXXX")
trap 'rm -rf "$TEST_ROOT"' EXIT HUP INT TERM

TEST_HOME="$TEST_ROOT/home"
mkdir -p "$TEST_HOME"

legacy_alias_output=$( \
  HOME="$TEST_HOME" \
  CONFIG_DIR="$TEST_HOME/.config" \
  BACKPACK_AGENTS_DIR="$TEST_HOME/.agents" \
  CODEX_HOME="$TEST_HOME/.codex" \
  CLAUDE_CONFIG_DIR="$TEST_HOME/.claude" \
  SUPER_CONFIG_DIR="$TEST_HOME/.super.engineering" \
  BACKPACK_BIN_DIR="$TEST_HOME/.local/bin" \
  BACKPACK_ROOT="$BACKPACK_ROOT" \
  "$BACKPACK_ROOT/bootstrap/install.sh" cockpit --all-hosts --dry-run --without-rtk)

printf '%s' "$legacy_alias_output" | grep -q 'cockpit.*deprecated.*install engineering' || {
  printf '✗ legacy cockpit alias did not explain its engineering replacement\n' >&2
  exit 1
}

output=$(printf '5\ny\n' | \
  HOME="$TEST_HOME" \
  CONFIG_DIR="$TEST_HOME/.config" \
  BACKPACK_AGENTS_DIR="$TEST_HOME/.agents" \
  CODEX_HOME="$TEST_HOME/.codex" \
  CLAUDE_CONFIG_DIR="$TEST_HOME/.claude" \
  SUPER_CONFIG_DIR="$TEST_HOME/.super.engineering" \
  BACKPACK_BIN_DIR="$TEST_HOME/.local/bin" \
  BACKPACK_ROOT="$BACKPACK_ROOT" \
  "$BACKPACK_ROOT/bootstrap/install.sh" engineering --without-rtk)

printf '%s' "$output" | grep -q 'Backpack Engineering installed for all supported tools' || {
  printf '✗ interactive Backpack Engineering install did not complete\n' >&2
  exit 1
}

test ! -e "$TEST_HOME/.copilot" || {
  printf '✗ all-hosts install unexpectedly created GitHub Copilot configuration\n' >&2
  exit 1
}

jq -e '.default_tool == "codex" and .experimental.agent_orchestration == true' \
  "$TEST_HOME/.super.engineering/settings.json" >/dev/null || {
  printf '✗ all-hosts install did not configure portable Super defaults\n' >&2
  exit 1
}

jq -e '.codex.effort == "medium" and .opencode.effort == "high" and (.codex | has("model_id") | not)' \
  "$TEST_HOME/.super.engineering/chat-defaults.json" >/dev/null || {
  printf '✗ all-hosts install pinned a model or missed Super chat defaults\n' >&2
  exit 1
}

test -L "$TEST_HOME/.local/bin/backpack" || {
  printf '✗ interactive Backpack Engineering install did not link the Backpack command\n' >&2
  exit 1
}

test -L "$TEST_HOME/.config/opencode/AGENTS.md" || {
  printf '✗ OpenCode install did not link the portable doctrine\n' >&2
  exit 1
}

grep -q 'reply yes once it is active' "$TEST_HOME/.config/opencode/AGENTS.md" || {
  printf '✗ Backpack Engineering doctrine does not explain manual model switching before confirmation\n' >&2
  exit 1
}

for codex_agent in backpack-code-review backpack-product-qa; do
  test -L "$TEST_HOME/.codex/agents/$codex_agent.toml" || {
    printf '✗ Codex install did not link the %s agent\n' "$codex_agent" >&2
    exit 1
  }
done

if grep -Rq '^model:' "$TEST_HOME/.claude/agents"; then
  printf '✗ Claude adapter pins a model instead of inheriting the user choice\n' >&2
  exit 1
fi

for claude_readonly_agent in plan review qa design; do
  grep -q '^permissionMode: plan$' "$TEST_HOME/.claude/agents/$claude_readonly_agent.md" || {
    printf '✗ Claude %s agent is not constrained by native plan permissions\n' "$claude_readonly_agent" >&2
    exit 1
  }
done

for backpack_skill in backpack-enhance-prompt backpack-pattern-scan backpack-pattern-capture backpack-validate backpack-learn backpack-start-work; do
  test -L "$TEST_HOME/.agents/skills/$backpack_skill" || {
    printf '✗ Backpack Engineering install did not link the %s core skill\n' "$backpack_skill" >&2
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

grep -q '^agent: plan$' "$TEST_HOME/.config/opencode/commands/backpack-brainstorm.md" || {
  printf '✗ OpenCode backpack-brainstorm command is not pinned to plan\n' >&2
  exit 1
}

grep -q '^agent: product-design$' "$TEST_HOME/.config/opencode/commands/backpack-design.md" || {
  printf '✗ OpenCode backpack-design command does not delegate to product-design\n' >&2
  exit 1
}

grep -A 2 '^agent: product-design$' "$TEST_HOME/.config/opencode/commands/backpack-design.md" | grep -q '^subtask: true$' || {
  printf '✗ OpenCode backpack-design command is not isolated as a subtask\n' >&2
  exit 1
}

if grep -Eq '"(model|small_model)"[[:space:]]*:' "$TEST_HOME/.config/opencode/opencode.json" ||
   grep -REq '^(model|variant):' "$TEST_HOME/.config/opencode/agents"; then
  printf '✗ OpenCode adapter pins a provider instead of inheriting the session model\n' >&2
  exit 1
fi

grep -A 14 '"plan": {' "$TEST_HOME/.config/opencode/opencode.json" | grep -q '"bash": "deny"' || {
  printf '✗ OpenCode plan shell is not hard-denied\n' >&2
  exit 1
}

grep -A 14 '"plan": {' "$TEST_HOME/.config/opencode/opencode.json" | grep -q '"edit": "deny"' || {
  printf '✗ OpenCode plan edits are not hard-denied\n' >&2
  exit 1
}

grep -A 14 '"build": {' "$TEST_HOME/.config/opencode/opencode.json" | grep -q '"bash": "ask"' || {
  printf '✗ OpenCode build shell does not require approval\n' >&2
  exit 1
}

grep -A 16 '"review": {' "$TEST_HOME/.config/opencode/opencode.json" | grep -q '"bash": "deny"' || {
  printf '✗ OpenCode review shell is not hard-denied\n' >&2
  exit 1
}

grep -A 16 '"review": {' "$TEST_HOME/.config/opencode/opencode.json" | grep -q '"edit": "deny"' || {
  printf '✗ OpenCode review edits are not hard-denied\n' >&2
  exit 1
}

grep -q '^  bash: deny$' "$TEST_HOME/.config/opencode/agents/qa.md" || {
  printf '✗ OpenCode Product QA shell is not hard-denied\n' >&2
  exit 1
}

grep -q '^  edit: deny$' "$TEST_HOME/.config/opencode/agents/qa.md" || {
  printf '✗ OpenCode Product QA edits are not hard-denied\n' >&2
  exit 1
}

if grep -R 'capture.sh' "$TEST_HOME/.config/opencode/opencode.json" "$TEST_HOME/.config/opencode/prompts/plan.md" "$TEST_HOME/.config/opencode/prompts/review.md" >/dev/null 2>&1; then
  printf '✗ OpenCode read-only agents retain a backpack-pattern-capture shell exception\n' >&2
  exit 1
fi

for command_path in "$TEST_HOME/.config/opencode/commands"/*.md; do
  command_name=$(basename "$command_path")
  case "$command_name" in
    backpack-brainstorm.md|backpack-design.md|backpack-review.md|backpack-qa.md) ;;
    *)
      printf '✗ OpenCode installed unexpected or unnamespaced command: %s\n' "$command_name" >&2
      exit 1
      ;;
  esac
done

for duplicate in brainstorm design review qa validate learn start-work pattern-scan refine capture; do
  if [ -e "$TEST_HOME/.config/opencode/commands/$duplicate.md" ]; then
    printf '✗ OpenCode preserved retired or unnamespaced command /%s\n' "$duplicate" >&2
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
for legacy_command in brainstorm design review qa; do
  printf 'legacy command\n' > "$TEST_HOME/.config/opencode/commands/$legacy_command.md"
done

replace_output=$( \
  HOME="$TEST_HOME" \
  CONFIG_DIR="$TEST_HOME/.config" \
  BACKPACK_AGENTS_DIR="$TEST_HOME/.agents" \
  CODEX_HOME="$TEST_HOME/.codex" \
  CLAUDE_CONFIG_DIR="$TEST_HOME/.claude" \
  SUPER_CONFIG_DIR="$TEST_HOME/.super.engineering" \
  BACKPACK_BIN_DIR="$TEST_HOME/.local/bin" \
  BACKPACK_ROOT="$BACKPACK_ROOT" \
  "$BACKPACK_ROOT/bootstrap/install.sh" engineering --opencode --without-rtk)

cmp "$BACKPACK_ROOT/engineering/adapters/opencode/opencode.json" "$TEST_HOME/.config/opencode/opencode.json" || {
  printf '✗ OpenCode reinstall did not replace the local opencode.json\n' >&2
  exit 1
}

test ! -e "$TEST_HOME/.config/opencode/local-only.txt" || {
  printf '✗ OpenCode reinstall preserved a local-only adapter file\n' >&2
  exit 1
}

for legacy_command in brainstorm design review qa; do
  test ! -e "$TEST_HOME/.config/opencode/commands/$legacy_command.md" || {
    printf '✗ OpenCode reinstall preserved retired command /%s\n' "$legacy_command" >&2
    exit 1
  }
done

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
  "$GENERAL_HOME/.copilot/hooks" \
  "$GENERAL_HOME/.copilot/instructions" \
  "$GENERAL_HOME/.superconductor" \
  "$GENERAL_HOME/.agents/skills/prompt-refinement" \
  "$GENERAL_HOME/.agents/skills/cockpit-enhance-prompt" \
  "$GENERAL_HOME/.config/fish" \
  "$GENERAL_HOME/.config/nvim" \
  "$GENERAL_HOME/.config/ghostty"

printf '{"local-only": true}\n' > "$GENERAL_HOME/.config/opencode/opencode.json"
printf 'local codex\n' > "$GENERAL_HOME/.codex/AGENTS.md"
printf 'local codex agent\n' > "$GENERAL_HOME/.codex/agents/local.toml"
printf 'legacy code review agent\n' > "$GENERAL_HOME/.codex/agents/cockpit-code-review.toml"
printf 'legacy product qa agent\n' > "$GENERAL_HOME/.codex/agents/cockpit-product-qa.toml"
printf 'model = "personal-model"\n' > "$GENERAL_HOME/.codex/config.toml"
printf 'local claude rule\n' > "$GENERAL_HOME/.claude/rules/backpack.md"
printf 'local claude agent\n' > "$GENERAL_HOME/.claude/agents/local.md"
printf 'local copilot\n' > "$GENERAL_HOME/.copilot/copilot-instructions.md"
printf 'legacy copilot\n' > "$GENERAL_HOME/.copilot/instructions/backpack.instructions.md"
printf '{"hooks":{"PreToolUse":[{"command": "rtk hook copilot"}]}}\n' > "$GENERAL_HOME/.copilot/hooks/rtk-rewrite.json"
printf '{"hooks":{"PreToolUse":[{"command": "client hook"}]}}\n' > "$GENERAL_HOME/.copilot/hooks/client.json"
printf '%s\n' '{"default_tool":"copilot","runtime_local":{"keep":true},"provider_profiles":{"client":{"enabled":true}},"experimental":{"enabled_providers":["github_copilot"]}}' > "$GENERAL_HOME/.superconductor/settings.json"
printf '%s\n' '{"codex":{"model_id":"client-local-model","effort":"low"}}' > "$GENERAL_HOME/.superconductor/chat-defaults.json"
ln -s "$GENERAL_HOME/.superconductor" "$GENERAL_HOME/.super.engineering"
printf 'local legacy skill\n' > "$GENERAL_HOME/.agents/skills/prompt-refinement/SKILL.md"
printf 'legacy cockpit skill\n' > "$GENERAL_HOME/.agents/skills/cockpit-enhance-prompt/SKILL.md"
printf 'local fish\n' > "$GENERAL_HOME/.config/fish/local.fish"
printf 'local nvim\n' > "$GENERAL_HOME/.config/nvim/local.lua"
printf 'local ghostty\n' > "$GENERAL_HOME/.config/ghostty/local.conf"

everything_output=$( \
  HOME="$GENERAL_HOME" \
  CONFIG_DIR="$GENERAL_HOME/.config" \
  BACKPACK_AGENTS_DIR="$GENERAL_HOME/.agents" \
  CODEX_HOME="$GENERAL_HOME/.codex" \
  CLAUDE_CONFIG_DIR="$GENERAL_HOME/.claude" \
  BACKPACK_BIN_DIR="$GENERAL_HOME/.local/bin" \
  BACKPACK_ROOT="$BACKPACK_ROOT" \
  "$BACKPACK_ROOT/bootstrap/install.sh" everything --personal --without-rtk)

cmp "$BACKPACK_ROOT/engineering/adapters/opencode/opencode.json" "$GENERAL_HOME/.config/opencode/opencode.json" || {
  printf '✗ Everything install did not replace OpenCode\n' >&2
  exit 1
}

for managed_link in \
  "$GENERAL_HOME/.codex/AGENTS.md" \
  "$GENERAL_HOME/.codex/agents/backpack-code-review.toml" \
  "$GENERAL_HOME/.codex/agents/backpack-product-qa.toml" \
  "$GENERAL_HOME/.claude/rules/backpack.md" \
  "$GENERAL_HOME/.claude/agents" \
  "$GENERAL_HOME/.agents/skills/backpack-enhance-prompt" \
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

for legacy_path in \
  "$GENERAL_HOME/.codex/agents/cockpit-code-review.toml" \
  "$GENERAL_HOME/.codex/agents/cockpit-product-qa.toml" \
  "$GENERAL_HOME/.agents/skills/cockpit-enhance-prompt"; do
  test ! -e "$legacy_path" && test ! -L "$legacy_path" || {
    printf '✗ Everything install preserved legacy Backpack path: %s\n' "$legacy_path" >&2
    exit 1
  }
done

grep -q '^local copilot$' "$GENERAL_HOME/.copilot/copilot-instructions.md" || {
  printf '✗ Everything install changed client-owned Copilot instructions\n' >&2
  exit 1
}

grep -q '^legacy copilot$' "$GENERAL_HOME/.copilot/instructions/backpack.instructions.md" || {
  printf '✗ Everything install changed external Copilot instructions\n' >&2
  exit 1
}

grep -q 'rtk hook copilot' "$GENERAL_HOME/.copilot/hooks/rtk-rewrite.json" || {
  printf '✗ Everything install changed a client-owned Copilot hook\n' >&2
  exit 1
}

grep -q 'client hook' "$GENERAL_HOME/.copilot/hooks/client.json" || {
  printf '✗ Everything install changed an externally owned Copilot hook\n' >&2
  exit 1
}

grep -q '^model = "personal-model"$' "$GENERAL_HOME/.codex/config.toml" || {
  printf '✗ Everything install changed personal Codex configuration\n' >&2
  exit 1
}

jq -e '.default_tool == "codex" and .experimental.agent_orchestration == true' \
  "$GENERAL_HOME/.superconductor/settings.json" >/dev/null || {
  printf '✗ Everything install did not merge portable Super settings\n' >&2
  exit 1
}

jq -e '.runtime_local.keep == true and .provider_profiles.client.enabled == true and (.experimental.enabled_providers | index("github_copilot")) != null' \
  "$GENERAL_HOME/.superconductor/settings.json" >/dev/null || {
  printf '✗ Everything install replaced Super runtime, provider, or Copilot-owned state\n' >&2
  exit 1
}

jq -e '.codex.model_id == "client-local-model" and .codex.effort == "medium" and .opencode.effort == "high"' \
  "$GENERAL_HOME/.superconductor/chat-defaults.json" >/dev/null || {
  printf '✗ Everything install did not preserve the local Super model while merging reasoning defaults\n' >&2
  exit 1
}

grep -Fq 'test "$PWD" = "$HOME"' "$GENERAL_HOME/.config/fish/config.fish" || {
  printf '✗ Fish config does not preserve an inherited project directory\n' >&2
  exit 1
}

grep -Fq 'not contains -- "$HOME/.local/bin" $PATH' "$GENERAL_HOME/.config/fish/conf.d/backpack-path.fish" || {
  printf '✗ Fish shell install does not add Backpack bin directory to PATH\n' >&2
  exit 1
}

general_backup=$(printf '%s\n' "$everything_output" | sed -n 's/^Backups: //p' | tail -n 1)
test -n "$general_backup" || {
  printf '✗ Everything install did not report the recovery backup\n' >&2
  exit 1
}

for backup_marker in \
  "$general_backup$GENERAL_HOME/.codex/AGENTS.md" \
  "$general_backup$GENERAL_HOME/.codex/agents/cockpit-code-review.toml" \
  "$general_backup$GENERAL_HOME/.codex/agents/cockpit-product-qa.toml" \
  "$general_backup$GENERAL_HOME/.claude/agents/local.md" \
  "$general_backup$GENERAL_HOME/.agents/skills/prompt-refinement/SKILL.md" \
  "$general_backup$GENERAL_HOME/.agents/skills/cockpit-enhance-prompt/SKILL.md" \
  "$general_backup$GENERAL_HOME/.super.engineering/settings.json" \
  "$general_backup$GENERAL_HOME/.super.engineering/chat-defaults.json" \
  "$general_backup$GENERAL_HOME/.config/fish/local.fish"; do
  test -f "$backup_marker" || {
    printf '✗ Everything install did not back up managed path: %s\n' "$backup_marker" >&2
    exit 1
  }
done

for backpack_skill in backpack-enhance-prompt backpack-pattern-scan backpack-pattern-capture backpack-validate backpack-learn backpack-start-work; do
  grep -q 'In GitHub Copilot, do not use this skill' \
    "$BACKPACK_ROOT/engineering/portable/skills/$backpack_skill/SKILL.md" || {
      printf '✗ %s is not disabled in GitHub Copilot\n' "$backpack_skill" >&2
      exit 1
    }
done

SUPER_HOME="$TEST_ROOT/super-home"
mkdir -p "$SUPER_HOME/.superconductor"
ln -s "$SUPER_HOME/.superconductor" "$SUPER_HOME/.super.engineering"
printf '%s\n' '{"default_tool":"copilot","provider_profiles":{"client":{"enabled":true}}}' > "$SUPER_HOME/.superconductor/settings.json"
printf '%s\n' '{"codex":{"model_id":"local-model"}}' > "$SUPER_HOME/.superconductor/chat-defaults.json"

HOME="$SUPER_HOME" \
CONFIG_DIR="$SUPER_HOME/.config" \
BACKPACK_AGENTS_DIR="$SUPER_HOME/.agents" \
CODEX_HOME="$SUPER_HOME/.codex" \
CLAUDE_CONFIG_DIR="$SUPER_HOME/.claude" \
BACKPACK_BIN_DIR="$SUPER_HOME/.local/bin" \
BACKPACK_ROOT="$BACKPACK_ROOT" \
  "$BACKPACK_ROOT/bootstrap/install.sh" engineering --super --personal --without-rtk >/dev/null

jq -e '.default_tool == "codex" and .provider_profiles.client.enabled == true' \
  "$SUPER_HOME/.superconductor/settings.json" >/dev/null || {
  printf '✗ dedicated Super install did not merge portable settings safely\n' >&2
  exit 1
}
test "$(readlink "$SUPER_HOME/.super.engineering")" = "$SUPER_HOME/.superconductor" || {
  printf '✗ dedicated Super install changed the official data alias\n' >&2
  exit 1
}
grep -qx 'super' "$SUPER_HOME/.config/backpack/installed-components" || {
  printf '✗ dedicated Super install did not record its installed component\n' >&2
  exit 1
}

MIGRATION_HOME="$TEST_ROOT/migration-home"
mkdir -p "$MIGRATION_HOME/.superconductor" "$MIGRATION_HOME/bin"
cp "$BACKPACK_ROOT/engineering/adapters/super/settings.json" "$MIGRATION_HOME/.superconductor/settings.json"
cp "$BACKPACK_ROOT/engineering/adapters/super/chat-defaults.json" "$MIGRATION_HOME/.superconductor/chat-defaults.json"
printf '%s\n' '#!/usr/bin/env sh' 'test "$1" = migrate-data' 'ln -s "$HOME/.superconductor" "$HOME/.super.engineering"' > "$MIGRATION_HOME/bin/sc"
chmod +x "$MIGRATION_HOME/bin/sc"

PATH="$MIGRATION_HOME/bin:$PATH" \
HOME="$MIGRATION_HOME" \
CONFIG_DIR="$MIGRATION_HOME/.config" \
BACKPACK_AGENTS_DIR="$MIGRATION_HOME/.agents" \
CODEX_HOME="$MIGRATION_HOME/.codex" \
CLAUDE_CONFIG_DIR="$MIGRATION_HOME/.claude" \
BACKPACK_BIN_DIR="$MIGRATION_HOME/.local/bin" \
BACKPACK_ROOT="$BACKPACK_ROOT" \
  "$BACKPACK_ROOT/bootstrap/install.sh" engineering --super --personal --without-rtk >/dev/null

test -d "$MIGRATION_HOME/.superconductor" &&
  test "$(readlink "$MIGRATION_HOME/.super.engineering")" = "$MIGRATION_HOME/.superconductor" || {
  printf '✗ Super migration did not preserve old storage behind the new alias\n' >&2
  exit 1
}

NOOP_HOME="$TEST_ROOT/noop-migration-home"
mkdir -p "$NOOP_HOME/.superconductor" "$NOOP_HOME/bin"
cp "$BACKPACK_ROOT/engineering/adapters/super/settings.json" "$NOOP_HOME/.superconductor/settings.json"
cp "$BACKPACK_ROOT/engineering/adapters/super/chat-defaults.json" "$NOOP_HOME/.superconductor/chat-defaults.json"
printf '%s\n' '#!/usr/bin/env sh' 'test "$1" = migrate-data' 'exit 0' > "$NOOP_HOME/bin/sc"
chmod +x "$NOOP_HOME/bin/sc"

if PATH="$NOOP_HOME/bin:$PATH" \
   HOME="$NOOP_HOME" \
   CONFIG_DIR="$NOOP_HOME/.config" \
   BACKPACK_BIN_DIR="$NOOP_HOME/.local/bin" \
   BACKPACK_ROOT="$BACKPACK_ROOT" \
   "$BACKPACK_ROOT/bootstrap/install.sh" engineering --super --personal --without-rtk >/dev/null 2>&1; then
  printf '✗ Super install accepted a no-op data migration\n' >&2
  exit 1
fi
test ! -e "$NOOP_HOME/.super.engineering" && test ! -L "$NOOP_HOME/.super.engineering" || {
  printf '✗ failed Super migration created an independent new data folder\n' >&2
  exit 1
}

PARTIAL_HOME="$TEST_ROOT/partial-super-home"
mkdir -p "$PARTIAL_HOME/.superconductor"
ln -s "$PARTIAL_HOME/.superconductor" "$PARTIAL_HOME/.super.engineering"
printf '%s\n' '{"default_tool":"copilot","local_marker":true}' > "$PARTIAL_HOME/.superconductor/settings.json"
printf '{invalid json\n' > "$PARTIAL_HOME/.superconductor/chat-defaults.json"
if HOME="$PARTIAL_HOME" \
   CONFIG_DIR="$PARTIAL_HOME/.config" \
   BACKPACK_BIN_DIR="$PARTIAL_HOME/.local/bin" \
   BACKPACK_ROOT="$BACKPACK_ROOT" \
   "$BACKPACK_ROOT/bootstrap/install.sh" engineering --super --personal --without-rtk >/dev/null 2>&1; then
  printf '✗ Super install accepted invalid existing chat defaults\n' >&2
  exit 1
fi
jq -e '.default_tool == "copilot" and .local_marker == true' \
  "$PARTIAL_HOME/.superconductor/settings.json" >/dev/null || {
  printf '✗ Super install partially changed settings before rejecting invalid chat defaults\n' >&2
  exit 1
}

copilot_error="$TEST_ROOT/copilot-error.txt"
if HOME="$TEST_HOME" \
   BACKPACK_ROOT="$BACKPACK_ROOT" \
   "$BACKPACK_ROOT/bootstrap/install.sh" engineering --copilot --without-rtk 2>"$copilot_error"; then
  printf '✗ Backpack still accepts GitHub Copilot as an installation target\n' >&2
  exit 1
fi
grep -q 'GitHub Copilot is client-owned and is not installed by Backpack' "$copilot_error" || {
  printf '✗ rejected GitHub Copilot install does not explain the ownership boundary\n' >&2
  exit 1
}

check_output=$( \
  HOME="$TEST_HOME" \
  CONFIG_DIR="$TEST_HOME/.config" \
  BACKPACK_AGENTS_DIR="$TEST_HOME/.agents" \
  CODEX_HOME="$TEST_HOME/.codex" \
  CLAUDE_CONFIG_DIR="$TEST_HOME/.claude" \
  SUPER_CONFIG_DIR="$TEST_HOME/.super.engineering" \
  BACKPACK_BIN_DIR="$TEST_HOME/.local/bin" \
  BACKPACK_ROOT="$BACKPACK_ROOT" \
  "$TEST_HOME/.local/bin/backpack" check)

printf '%s' "$check_output" | grep -q 'installation matches Backpack' || {
  printf '✗ installed Backpack command did not validate its own installation\n' >&2
  exit 1
}

ln -s "$TEST_HOME/.config/opencode/commands/backpack-review.md" \
  "$TEST_HOME/.config/opencode/commands/obsolete.md"
if HOME="$TEST_HOME" \
   CONFIG_DIR="$TEST_HOME/.config" \
   BACKPACK_AGENTS_DIR="$TEST_HOME/.agents" \
   CODEX_HOME="$TEST_HOME/.codex" \
   CLAUDE_CONFIG_DIR="$TEST_HOME/.claude" \
   SUPER_CONFIG_DIR="$TEST_HOME/.super.engineering" \
   BACKPACK_BIN_DIR="$TEST_HOME/.local/bin" \
   BACKPACK_ROOT="$BACKPACK_ROOT" \
   "$TEST_HOME/.local/bin/backpack" check opencode >/dev/null 2>&1; then
  printf '✗ installation check accepted an obsolete symlinked OpenCode command\n' >&2
  exit 1
fi
rm "$TEST_HOME/.config/opencode/commands/obsolete.md"

mv "$TEST_HOME/.super.engineering/chat-defaults.json" "$TEST_ROOT/chat-defaults.valid.json"
printf '{invalid json\n' > "$TEST_HOME/.super.engineering/chat-defaults.json"
if HOME="$TEST_HOME" \
   CONFIG_DIR="$TEST_HOME/.config" \
   BACKPACK_AGENTS_DIR="$TEST_HOME/.agents" \
   CODEX_HOME="$TEST_HOME/.codex" \
   CLAUDE_CONFIG_DIR="$TEST_HOME/.claude" \
   SUPER_CONFIG_DIR="$TEST_HOME/.super.engineering" \
   BACKPACK_BIN_DIR="$TEST_HOME/.local/bin" \
   BACKPACK_ROOT="$BACKPACK_ROOT" \
   "$TEST_HOME/.local/bin/backpack" check engineering >/dev/null 2>&1; then
  printf '✗ installation check accepted corrupt Super JSON\n' >&2
  exit 1
fi
mv "$TEST_ROOT/chat-defaults.valid.json" "$TEST_HOME/.super.engineering/chat-defaults.json"

rm "$TEST_HOME/.codex/agents/backpack-code-review.toml"
ln -s "$BACKPACK_ROOT/engineering/adapters/codex/agents/backpack-product-qa.toml" \
  "$TEST_HOME/.codex/agents/backpack-code-review.toml"
if HOME="$TEST_HOME" \
   CONFIG_DIR="$TEST_HOME/.config" \
   BACKPACK_AGENTS_DIR="$TEST_HOME/.agents" \
   CODEX_HOME="$TEST_HOME/.codex" \
   CLAUDE_CONFIG_DIR="$TEST_HOME/.claude" \
   SUPER_CONFIG_DIR="$TEST_HOME/.super.engineering" \
   BACKPACK_BIN_DIR="$TEST_HOME/.local/bin" \
   BACKPACK_ROOT="$BACKPACK_ROOT" \
   "$TEST_HOME/.local/bin/backpack" status >/dev/null 2>&1; then
  printf '✗ installation status accepted a Codex agent linked to the wrong source\n' >&2
  exit 1
fi

printf '✓ interactive Backpack Engineering install contract\n'
