# Backpack

Portable macOS engineering environment: Backpack Engineering, machine setup,
project skills, and durable learning memory.

## Structure

```txt
bootstrap/               setup and validation scripts
engineering/portable/   host-agnostic workflow, core skills, and curated skill catalogue
engineering/adapters/   thin Super, Codex, Claude, and OpenCode adapters
memory/                  durable personal learning: craft, AI, concepts, books, playbooks
```

## Boundaries

- `backpack/memory` is personal, durable, and reusable.
- Client mission notes live outside this repo.
- GitHub Copilot configuration is client-owned and lives outside this repo.
- Project truth lives in each project repo (`README.md`, `AGENTS.md`, `docs/`).
- Secrets, SSH keys, tokens, client-specific certs, and local state are not committed.
- Client-specific providers and models may be applied locally after installation,
  but the next OpenCode installation intentionally resets them from Backpack.

## Quick start

Clone the repository wherever you keep your projects, enter it, then launch the
menu:

```sh
git clone git@github.com:AlxTx/backpack.git
cd backpack
./backpack
```

`./backpack` means “run the `backpack` file from this folder”. The first
installation links `backpack` into `~/.local/bin`. Selecting **Shell** or
**Everything** configures Fish to include that directory; start a new Fish
session afterward, then use it from anywhere.

The menu validates the repository, previews interactive plans, and asks before
changing local configuration.

The menu clearly separates **Backpack Engineering** — the portable workflow used inside AI
tools — from this Mac's shell, editor, and terminal configuration. The installer
uses arrow-key menus when `gum` is available and falls back to a numbered menu.

## Common commands

| Need | Command |
|---|---|
| Open the main menu | `backpack` |
| Open the project-skill menu | `backpack skills` |
| Choose what to install | `backpack install` |
| Validate repository sources only | `backpack doctor` |
| Verify the installed state and detect drift | `backpack check` |
| Show installed state with integrity checks | `backpack status` |
| List curated skills with project status | `backpack list` |
| Find a curated skill by need | `backpack find design` |
| Inspect a skill | `backpack info impeccable` |
| Add the UX/UI skill to this project | `backpack add impeccable` |
| Remove a skill from this project | `backpack remove impeccable` |
| Install everything on a personal Mac | `backpack install everything --personal` |
| Install everything on a client Mac | `backpack install everything --client` |
| Install Backpack Engineering for every supported personal host | `backpack install engineering --all-hosts` |
| Install Backpack Engineering for Codex | `backpack install engineering --codex` |
| Install Backpack Engineering for Claude Code | `backpack install engineering --claude` |
| Install portable Super preferences | `backpack install engineering --super` |
| Replace Backpack Engineering for OpenCode from Backpack | `backpack install engineering --opencode` |

A direct target applies immediately; use `--dry-run` for a read-only preview.
Applicable Backpack Engineering targets install [`rtk`](https://github.com/rtk-ai/rtk)
through Homebrew when needed; use `--without-rtk` to opt out.

## Shared AI workflow

The canonical rules and skills live in `engineering/portable/`. Host-specific files
live under `engineering/adapters/<host>/`. The installer combines the selected
adapter with the portable core.

Backpack Engineering installs only the small workflow core required everywhere. Specialized
skills are chosen per project instead of being injected globally. Use the
interactive `backpack skills` menu, or `backpack find`
to search Backpack's curated catalogue, `backpack info` to inspect scope and limits,
and `backpack add` or `backpack remove` to change the current project. `backpack list` shows the
whole curated catalogue with an `available` or `installed` status for the current project.

Backpack orchestrates; installed skills provide specialized guidance. Skill metadata
activates them automatically when the request matches. Impeccable is the single
curated UX/UI skill; project requirements and design-system conventions remain
authoritative.

| Host | CLI | Desktop app |
|---|---|---|
| Codex | `~/.codex/AGENTS.md` | Uses the same instruction source |
| Claude Code | `~/.claude/rules/backpack.md`, agents, and skills | Code tab shares the same local configuration |
| OpenCode | `~/.config/opencode/` | Uses the same configuration as CLI and TUI |
| Super | `~/.super.engineering/settings.json`, `chat-defaults.json` | Portable preferences merged without runtime state; upgraded installs retain `.superconductor` as aliased storage |
GitHub Copilot is deliberately excluded from Backpack installation. Its workflow,
instructions, plugins, hooks, and skills remain client-owned. Backpack skills
that are visible through the shared agent-skills standard declare Copilot as an
unsupported host and must not run there.

Repository-level instructions remain project truth and can add client-specific
constraints. Backpack never creates or commits them automatically.

## Daily Backpack Engineering flow

Backpack Engineering follows **Plan → Build → Validate → Learn**. Before substantive work, it
compares the active model with the task when the host exposes that information:
Terra covers everyday and settled work, Sol covers uncertainty and risky review,
and Astra is reserved for the hardest consequential work. Backpack Engineering asks `yes/no`
before recommending either a safer upgrade or a risk-free cheaper downgrade; it
never switches models silently. When the host requires a manual change, Backpack Engineering
says so before asking: switch in the model selector, then answer `yes` once the
recommended model is active, or `no` to keep the current model.

In OpenCode, use `Tab` for the `build` and read-only `plan` primary agents. Its
host-specific commands are `/backpack-brainstorm`, `/backpack-design`,
`/backpack-review`, and `/backpack-qa`. Shared lifecycle capabilities remain
portable skills, notably `backpack-validate`, `backpack-learn`, and
`backpack-start-work`, rather than duplicate slash commands.

See [Backpack Engineering routing and command flow](docs/backpack-routing.md) for the complete
usage map.

## Visible Backpack Engineering activity

For a non-trivial task, hosts using Backpack Engineering expose the active phase,
then any skill, agent, plugin, or integration actually activated. Native host
events are preferred; otherwise Backpack emits a compact one-line fallback such
as `[Backpack - build] · [Skill] impeccable`. The status marker stays
visible on every line: Backpack, then the active phase; the bracketed label makes
the capability type immediately scannable. It never duplicates an activation
the host already displays. This makes the workflow visible without exposing
private model reasoning or producing a log for every shell command. After
updating Backpack, restart the host.

Every installer target is canonical: Backpack replaces each selected path from
the repository instead of retaining a divergent local copy. OpenCode is copied
as a full adapter into `~/.config/opencode/`; other hosts and machine tools use
canonical links for the paths Backpack owns.

## Safety and profiles

Interactive installation previews first; direct targets apply immediately.
Backpack backs up replaced entries under `~/.config.backup.<timestamp>/` and
leaves matching canonical links alone. Account data, tokens, histories, caches,
and host files outside Backpack's installation map are never targeted.
On client machines, use `--client` and keep providers, tokens, endpoints,
policies, and mission notes outside Backpack.

After installation, restart applications that load configuration at startup.
OpenCode must be restarted after adapter or skill updates.

See [installation details](docs/install.md) for every option and
[the host-agnostic AI workflow](docs/ai-workflow.md) for host boundaries.
