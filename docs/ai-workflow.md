# Host-agnostic AI workflow

Backpack is the source of truth for one personal engineering workflow.
Hosts consume the same doctrine and skills; host-specific configuration is
limited to capabilities the common standards cannot express.

## Canonical sources

See `cockpit/portable/AGENTS.md`, `cockpit/portable/MODELS.md`, and
`cockpit/portable/skills/`.

`AGENTS.md` defines classification, request routing, scope control, validation,
review priorities, pattern learning, and communication style. `MODELS.md` maps
the workflow to semantic Frontier, Balanced, and Fast tiers.

Skills follow the open agent-skills directory format and are installed once at
`~/.agents/skills`. Hosts advertise metadata and load a skill body only when
the request matches.

## Host adapters

| Host | Shared guidance | Shared skills | Adapter-only concerns |
|---|---|---|---|
| Codex | `~/.codex/AGENTS.md` | `~/.agents/skills` | models, plugins, MCP, desktop/CLI settings |
| OpenCode | `~/.config/opencode/AGENTS.md` | `~/.agents/skills` | agents, commands, permissions, provider/model |
| Other compatible hosts | global or repo `AGENTS.md` | `.agents/skills` | host permissions and UI |

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

# OpenCode adapter plus shared workflow
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
