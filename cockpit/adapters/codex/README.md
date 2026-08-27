# Codex adapter

Codex CLI and the Codex desktop app consume the portable workflow through
`~/.codex/AGENTS.md`, discover the minimal personal core through
`~/.agents/skills`, and discover project skills installed with `backpack add`
from the project's `.agents/skills` directory.

The system remains **Plan → Build → Validate → Learn**. Codex uses its native
conversation, Plan mode, skill UI, subagent surface, browser, annotations, diff,
and terminal instead of reproducing OpenCode's primary-agent and `/command` UI.

## Daily cookbook

| Need | Default interaction | Explicit entrypoint |
|---|---|---|
| Discuss, decide, or diagnose | Ask normally; Cockpit stays read-only | none needed |
| Produce an execution-ready plan | Select Codex Plan mode and ask for the plan | native Plan mode |
| Implement an approved change | Ask to build, fix, align, migrate, or remove | normal Codex thread |
| Validate the completed slice | Ask to validate delivery readiness | `@cockpit-validate` in the app or `$cockpit-validate` in CLI/IDE |
| Learn from finished work | Ask to learn from or retrospect on the slice | `@cockpit-learn` or `$cockpit-learn` |
| Prepare a safe work branch | Provide the work branch and remote base | `@cockpit-start-work` or `$cockpit-start-work` |
| Scan an unfamiliar codebase | Ask for a pattern scan and give the scope | `@pattern-scan` or `$pattern-scan` |

Natural language remains the default. Explicit skill invocation is useful when
the workflow boundary itself matters or when testing Cockpit behavior.

## Delivery guarantees

- `AGENTS.md` classifies the request and keeps discussion, diagnosis, planning,
  review, validation, and Learn read-only toward the product.
- `cockpit-validate` delegates two independent lenses to
  `cockpit_code_review` and `cockpit_product_qa`, both configured with a
  read-only sandbox, then consolidates the Ready-to-Ship status.
- the native Codex subagent surface exposes both validation threads for
  inspection;
- the Git delivery gate remains separate: Ready to Ship never authorizes a
  commit, push, merge, pull request, or deployment;
- Cockpit activity is announced through the portable `Cockpit › phase` event,
  while Codex renders skills, subagents, and tools through its native UI. The
  conversation does not duplicate those native chips with `[Skill]`, `[Agent]`,
  or explanatory status lines.

The adapter deliberately does not replace `~/.codex/config.toml`. Authentication,
settings, histories, caches, plugins, MCP servers, theme, and the user's model
choice remain untouched. Backpack manages only:

```txt
~/.codex/AGENTS.md
~/.codex/agents/cockpit-code-review.toml
~/.codex/agents/cockpit-product-qa.toml
~/.agents/skills/<Cockpit core>
```

Model selection follows `cockpit/portable/MODELS.md`: Terra/medium is the
recommended everyday thread, Sol/high suits difficult planning or review, and
Luna/medium suits a settled execution. The installer does not override an
explicit personal choice, and the Cockpit validation agents inherit the active
thread's model and reasoning settings.

Install only this adapter with:

```sh
backpack install cockpit --codex
```

Start a new Codex task after installation so instructions, skills, and custom
agents are rediscovered.
