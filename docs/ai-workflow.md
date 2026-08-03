# Host-agnostic AI workflow

Backpack is the source of truth for one personal engineering workflow.
Hosts consume the same doctrine and skills; host-specific configuration is
limited to capabilities the common standards cannot express.

## Canonical sources

See `cockpit/portable/AGENTS.md`, `cockpit/portable/MODELS.md`,
`cockpit/portable/skills/`, and `cockpit/adapters/`.

`AGENTS.md` defines classification, request routing, scope control, validation,
review priorities, pattern learning, and communication style. `MODELS.md` maps
the workflow to semantic Frontier, Balanced, and Fast tiers. Codex, GitHub
Copilot, OpenCode, and Claude Code consume this same core.

Skills follow the open agent-skills directory format and are installed once at
`~/.agents/skills`. Hosts advertise metadata and load a skill body only when
the request matches.

## Host adapters

All host-specific payloads live under `cockpit/adapters/<host>/`. An adapter may
contain a full local configuration template, a small set of subagents, or only
the installation mapping when the host directly consumes the portable files.

| Host | CLI/Desktop coverage | Shared guidance | Shared skills | Adapter-only concerns |
|---|---|---|---|---|
| Codex | Same portable files in CLI and desktop app | `~/.codex/AGENTS.md` | `~/.agents/skills` | models, plugins, MCP |
| GitHub Copilot | CLI automatic; App global instructions require one in-app paste | `~/.copilot/copilot-instructions.md` | `~/.agents/skills` | account, organization policies, repository instructions |
| OpenCode | Same configuration in CLI, TUI, desktop app, and GitHub Action | `~/.config/opencode/AGENTS.md` | `~/.agents/skills` | agents, commands, permissions, provider/model |
| Claude Code | CLI and Desktop Code tab share local configuration | `~/.claude/rules/backpack.md` | `~/.claude/skills` | subagents, hooks, permissions, provider/model |
| Other compatible hosts | Varies by host | global or repo `AGENTS.md` | `.agents/skills` | host permissions and UI |

Copilot CLI uses Backpack's personal instructions locally. After a successful
Copilot install, Backpack prints the canonical global-instructions block for the
GitHub Copilot App. `bootstrap/copilot-app-instructions.sh --copy` remains
available to recopy it later. Copilot cloud agents and code review use
repository-level `AGENTS.md` or
`.github/copilot-instructions.md`; Backpack deliberately leaves those files to
the client repository.

OpenCode keeps richer phase switching because its primary-agent model makes it
useful. Those modes are an interface over the common workflow, not a second
source of doctrine.

## Token discipline

- State shared rules once in `AGENTS.md`; adapter prompts contain only the delta
  required by that host or phase.
- Keep the always-loaded skill catalog small. Skill bodies are loaded only when
  the request matches.
- Remove repeated instructions, examples, and tools unless they encode a real
  requirement or fix a measured quality gap.
- Measure task success, tokens, latency, and cost on representative work before
  increasing model tier or reasoning effort.
- Route shell output through `rtk` when it is installed. It is an execution
  filter, not a second instruction corpus: OpenCode rewrites compatible commands
  automatically, while every other host inherits the portable shell rule.
- Use `bootstrap/install.sh --only ai --apply` to install RTK and activate the
  shared workflow for Codex, Copilot, OpenCode, and Claude Code on a new Mac.

## Visible execution context

Backpack does not expose private model reasoning. For non-trivial work it emits
a short public status before acting, then announces any selected skill, subagent,
plugin, or integration when it is actually activated. This is a portable
semantic event: use the host's native rendering when available, otherwise fall
back to a compact `Backpack · <event> · <name>` line. Never show both for the
same activation. This is an audit trail of the workflow, not a transcript of
every command or internal thought.

Hosts with a dedicated progress surface show it there; other hosts send the same
status in the conversation.

## Default loop

```txt
discuss/decide -> plan -> build -> review -> learn when reusable
```

Small explicit changes can go directly to build and targeted validation.
Planning and review depth scale with uncertainty, blast radius, and risk.

## Installation

```sh
# shared workflow
bootstrap/install.sh --only ai --apply

# one adapter only
bootstrap/install.sh --only codex --apply
bootstrap/install.sh --only claude --apply
bootstrap/install.sh --only copilot --apply
bootstrap/install.sh --only opencode --apply

# refresh the local OpenCode adapter without replacing providers/models
bootstrap/install.sh --only opencode --update --apply
```

The installer links canonical files, so edits in Backpack become visible after
starting a new host session. OpenCode's local `opencode.json` is preserved on
adapter updates.

## Boundaries

- Project truth stays in each project's `AGENTS.md`, README, docs, and tests.
- Client providers, endpoints, policies, secrets, and tokens stay local.
- Personal pattern captures stay outside client repositories.
- Add a host adapter only when the host cannot consume the common standards.
- Use plugins for external capabilities or independently maintained workflows,
  not as the default distribution mechanism for personal instructions.

## Compound Engineering decision

Compound Engineering is useful as an off-the-shelf, batteries-included workflow,
but its core plan/build/review/learn loop overlaps this personal workflow and its
large skill catalog adds always-visible metadata. It is therefore not part of the
default installation. Reinstall a focused capability only if a concrete need is
not covered here, such as a team-standard PR operation or an external service.
