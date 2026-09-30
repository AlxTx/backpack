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

The main menu has one **Install or refresh** entry. The installer then lets you
choose Backpack Engineering, this Mac's configuration, or everything. Direct
target commands use the same installer. Menus use arrow keys when `gum` is
available and fall back to numbered choices.

## Common commands

| Need | Command |
|---|---|
| Open the main menu | `backpack` |
| Open the project-skill menu | `backpack skills` |
| Install or refresh from this checkout | `backpack` → **Install or refresh**, or `backpack install` |
| Validate repository sources only | `backpack doctor` |
| Verify the installed state and detect drift | `backpack check` |
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
| Install portable Super preferences and commands | `backpack install engineering --super` |
| Replace Backpack Engineering for OpenCode from Backpack | `backpack install engineering --opencode` |

A direct target applies immediately; use `--dry-run` for a read-only preview.
`backpack status` remains an alias for `backpack check`.
Applicable Backpack Engineering targets install [`rtk`](https://github.com/rtk-ai/rtk)
through Homebrew when needed; use `--without-rtk` to opt out.
After a successful install or reinstall, Backpack shows what was installed and
up to four relevant commits since that target's last install. It compares the
local checkout; update the repository separately before reinstalling.

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

Backpack coordinates the delivery workflow; installed skills provide specialized
guidance. Host-native orchestration remains owned by the host: in Super, an
explicit orchestration request uses the current `sc` workflow and may coordinate
any locally enabled provider. Skill metadata activates installed skills
automatically when the request matches. Impeccable is the single curated UX/UI
skill; project requirements and design-system conventions remain authoritative.

For a project that builds an LLM, RAG, agent, multimodal, or MCP application,
inspect `backpack info ai-engineering`, then run `backpack add ai-engineering`
from that project's folder if the architecture guidance is useful. It is an
optional project skill, not part of the global Backpack Engineering core. The
condensed [IBM learning note](memory/ai/ibm-rag-agentic-ai.md) remains personal
reference material and is not loaded into every agent session.

| Host | CLI | Desktop app |
|---|---|---|
| Codex | `~/.codex/AGENTS.md` | Uses the same instruction source |
| Claude Code | `~/.claude/rules/backpack.md`, agents, and skills | Code tab shares the same local configuration |
| OpenCode | `~/.config/opencode/` | Uses the same configuration as CLI and TUI |
| Super | `~/.super.engineering/settings.json`, `chat-defaults.json` | Portable preferences merged without runtime state; current app-managed orchestration is injected by Super and uses `sc`; upgraded installs retain `.superconductor` as aliased storage |
GitHub Copilot is deliberately excluded from Backpack installation. Its workflow,
instructions, plugins, hooks, and skills remain client-owned. Backpack skills
that are visible through the shared agent-skills standard declare Copilot as an
unsupported host and must not run there.

Repository-level instructions remain project truth and can add client-specific
constraints. Backpack never creates or commits them automatically.

## Daily Backpack Engineering flow

Backpack Engineering shows **💭 Explore → 📋 Plan → 🛠️ Build → ⚖️ Validate → 📚 Learn**.
These are flexible steps, not required modes or documents. Explore includes
discussion and diagnosis; Kickoff guides a substantial initiative into Explore
or Plan, Team build is a Build variant, and Review is one Validate lens.
Before substantive work, Backpack compares the active model with the task when
the host exposes that information:
Terra covers everyday and settled work, Sol covers uncertainty and risky review,
and Astra is reserved for the hardest consequential work. Backpack Engineering asks `yes/no`
before recommending either a safer upgrade or a risk-free cheaper downgrade; it
never switches models silently. When the host requires a manual change, Backpack Engineering
says so before asking: switch in the model selector, then answer `yes` once the
recommended model is active, or `no` to keep the current model.

For a new or ongoing initiative, describe what you want to create or change and
share its existing brief, decisions, or work. If the context is unclear, Backpack
asks whether you are starting from scratch (**greenfield**) or evolving an
existing product or codebase (**brownfield**). It guides the relevant discovery,
requirements, UX, technical, and planning decisions one at a time, resuming from
what is already established. Ask for a visual checklist when you want to track
the current slice; a project-owned Markdown tracker is optional. You do not need
to select each activity or produce a fixed set of documents.
That view separates Discovery, Definition, Engineering, and Delivery so you can
see when the current slice moves from product direction into technical choices.
Backpack command names and status phase labels remain in English across hosts.
Select `backpack-kickoff` from the Codex skill picker when you want to launch
this guided conversation explicitly. In Claude Code, invoke `/backpack-kickoff`.
In Super, use the `🧭 Kickoff` custom command.
For a substantial approved Build, the optional `👥 Team build`
custom command asks Super to coordinate visible agents when work can be split
cleanly. Backpack still owns scope, integration, Code Review, Product QA, and
the Git delivery gate. `backpack install engineering --super` installs or updates
all five global Backpack commands. See the [Super adapter](engineering/adapters/super/README.md)
for their behavior.

For a new or ongoing project in Super:

1. Open the project folder and start a chat with your chosen provider.
2. Send your idea or attach the brief. For ongoing work, ask Backpack to resume
   from the brief, decisions, and delivered work and show a progress checklist.
3. Choose **🧭 Kickoff** from the worktree action card or
   Command Palette. Answer its questions in the same chat, one at a time.
4. Once the next slice and its proof are clear, ask Backpack to build it. Ask
   separately to create or update a project-owned Markdown tracker if you want
   the checklist to persist across chats.

After updating Backpack Engineering, refresh the provider you use, for example
`backpack install engineering --codex`, then start a new chat so it discovers
the updated skills and commands. Super custom commands are stored in Super and
are synchronized when you reinstall the Super adapter.

In OpenCode, use `Tab` for the `build` and read-only `plan` primary agents. Its
`/backpack-kickoff`, `/backpack-validate`, `/backpack-learn`, and
`/backpack-pattern-scan` commands load the corresponding portable skills.
`/backpack-brainstorm`, `/backpack-design`, `/backpack-review`, and
`/backpack-qa` use OpenCode-specific agents. Skill bodies remain the single
source for shared workflows.

See [Backpack Engineering routing and command flow](docs/backpack-routing.md) for the complete
usage map.

When an agent repeats a mistake or makes a consequential one, use
`backpack-learn` to capture the observed
case, check whether an existing control already covers it, and propose one
small correction with a way to observe improvement. See the
[harness feedback loop](docs/ai-workflow.md#improving-the-harness) for where that
correction belongs. This reuses Learn rather than adding another global command.

## Visible Backpack Engineering activity

For a non-trivial task, hosts using Backpack Engineering expose the active phase,
then any skill, agent, plugin, or integration actually activated. Native host
events are preferred; otherwise Backpack emits a compact one-line fallback such
as `🛠️ Build - [Skill] impeccable`. Status lines contain only a short activity
or capability label. Explanations and answers appear separately, without the
emoji marker. Backpack never duplicates an activation the host already displays.
This makes the workflow visible without exposing private model reasoning or
producing a log for every shell command. After updating Backpack, restart the host.

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
