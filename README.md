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

`./` means “from this folder”, so `./backpack` works in zsh, Bash, and Fish
without changing your `PATH`. The installer also links the command into
`~/.local/bin`. To type `backpack` from any folder, that directory must be on
your `PATH`: Backpack configures Fish when you select **Shell** or
**Everything**; [zsh setup](docs/install.md#zsh-and-other-shells) is one manual
step.

The menu validates the repository, previews interactive plans, and asks before
changing local configuration.

The main menu has one **Install or refresh** entry. The installer then lets you
choose Backpack Engineering, this Mac's configuration, or everything. Direct
target commands use the same installer. Menus use arrow keys when `gum` is
available and fall back to numbered choices.

## How to use Backpack Engineering

1. Open your project's folder in Super, Codex, Claude Code, or OpenCode and
   start a new chat.
2. For a new or substantial project, share the idea or brief and run **Kickoff**.
   For work already underway, share the existing decisions and ask Kickoff to
   resume. For a small, clear task, just describe it in the chat.
3. If you ran Kickoff, answer its next question. When the next deliverable is
   clear, say **“Build the next slice we just defined.”**
4. For a completed slice, run **Validate**. Review its Code Review and Product QA
   findings.
5. If you want Git delivery, say **“commit and push”** after reviewing the result.

See the [step-by-step guide](docs/backpack-routing.md) for the exact Kickoff and
Validate entrypoints in each tool, example messages, progress checklist, and
update steps.

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

Backpack displays **💭 Explore → 📋 Plan → 🛠️ Build → ⚖️ Validate → 📚 Learn** as
its flexible workflow. Kickoff guides the start of a substantial project; you do
not need to select every step. The [AI workflow reference](docs/ai-workflow.md)
explains the rules, models, host controls, and optional actions in detail.

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
