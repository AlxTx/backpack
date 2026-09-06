# Claude Code adapter

Claude Code CLI and the Claude Desktop Code tab share the same local
configuration. The portable workflow is linked to `~/.claude/rules/backpack.md`.
The minimal Cockpit core is linked into both `~/.claude/skills` and
`~/.agents/skills`; project skills are managed with `backpack add` and discovered
from project skill folders. This adapter adds the Claude-specific subagents
under `agents/`.

Installation replaces the Backpack rule, the complete Backpack agent directory,
and core-skill paths from their canonical sources. Claude authentication,
settings, histories, and unrelated host state remain untouched.

The delivery flow uses `plan` → `build` → `cockpit-validate` → optional
`cockpit-learn`. Shared capabilities are exposed once as portable skills;
Claude-specific agents exist only for host-native postures or independent Code
Review and Product QA lenses.

Plan, design, Code Review, and Product QA use Claude's native `plan` permission
mode. They may inspect and use read-only shell commands under Claude's permission
rules, but cannot edit files; Build remains the only implementation posture.

## Model selection

The adapter leaves every agent unpinned so Plan, Build, Review, Product QA, and
design inherit the model selected by the user. Cockpit applies the semantic tiers
from `cockpit/portable/MODELS.md` to the models available in Claude. When a
different model is materially safer or safely cheaper, select it through
Claude's native model control, then answer `yes` once active, or `no` to continue
with the current model. Accepting the recommendation alone never implies that a
manual switch occurred.

Install only this adapter with:

```sh
backpack install cockpit --claude
```
