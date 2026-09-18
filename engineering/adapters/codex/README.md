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
| Discuss, decide, or diagnose | Ask normally; Backpack Engineering stays read-only | none needed |
| Produce an execution-ready plan | Select Codex Plan mode and ask for the plan | native Plan mode |
| Implement an approved change | Ask to build, fix, align, migrate, or remove | normal Codex thread |
| Clarify or compact a prompt explicitly | Ask to improve the prompt | `@backpack-enhance-prompt` in the app or `$backpack-enhance-prompt` in CLI/IDE |
| Validate the completed slice | Ask to validate delivery readiness | `@backpack-validate` in the app or `$backpack-validate` in CLI/IDE |
| Learn from finished work | Ask to learn from or retrospect on the slice | `@backpack-learn` or `$backpack-learn` |
| Prepare a safe work branch | Provide the work branch and remote base | `@backpack-start-work` or `$backpack-start-work` |
| Scan an unfamiliar codebase | Ask for a pattern scan and give the scope | `@backpack-pattern-scan` or `$backpack-pattern-scan` |

Natural language remains the default. Explicit skill invocation is useful when
the workflow boundary itself matters or when testing Backpack Engineering behavior.

## Delivery guarantees

- `AGENTS.md` classifies the request and keeps discussion, diagnosis, planning,
  review, validation, and Learn read-only toward the product.
- `backpack-validate` delegates two independent lenses to
  `backpack_code_review` and `backpack_product_qa`, both configured with a
  read-only sandbox, then consolidates the Ready-to-Ship status.
- the native Codex subagent surface exposes both validation threads for
  inspection;
- the Git delivery gate remains separate: Ready to Ship never authorizes a
  commit, push, merge, pull request, or deployment;
- Backpack Engineering activity is announced through the portable `[Backpack - phase]` event,
  while Codex renders skills, subagents, and tools through its native UI. The
  conversation does not duplicate those native chips with `[Skill]`, `[Agent]`,
  or explanatory status lines.

The adapter deliberately does not replace `~/.codex/config.toml`. Authentication,
settings, histories, caches, plugins, MCP servers, theme, and the user's model
choice remain untouched. Backpack manages only:

```txt
~/.codex/AGENTS.md
~/.codex/agents/backpack-code-review.toml
~/.codex/agents/backpack-product-qa.toml
~/.agents/skills/<Backpack Engineering core>
```

Model selection follows `engineering/portable/MODELS.md`: Terra/medium is the
recommended everyday and settled-execution thread, Sol/high suits difficult
planning or review, and Astra/high is reserved for the hardest consequential
work. When the active model is available to the agent, Backpack Engineering proposes a
materially safer or cheaper choice before substantive work. Codex model selection
is user-controlled: switch in the native selector, then answer `yes` once the
recommended model is active, or `no` to keep the current model. The installer
does not override an explicit personal choice, and the Backpack Engineering validation agents
inherit the active thread's settings.

Install only this adapter with:

```sh
backpack install engineering --codex
```

Start a new Codex task after installation so instructions, skills, and custom
agents are rediscovered.
