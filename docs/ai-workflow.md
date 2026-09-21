# Host-agnostic AI workflow

Backpack is the source of truth for one personal engineering workflow.
Hosts consume the same doctrine and skills; host-specific configuration is
limited to capabilities the common standards cannot express.

## Canonical sources

See `engineering/portable/AGENTS.md`, `engineering/portable/MODELS.md`,
`engineering/portable/skills.core`, `engineering/portable/skills.tsv`, and
`engineering/adapters/`.

`AGENTS.md` defines classification, request routing, scope control, validation,
review priorities, pattern learning, and communication style. `MODELS.md` maps
the workflow to semantic Maximum, Frontier, and Balanced tiers. Codex, OpenCode,
and Claude Code consume this same core.

Skills follow the open agent-skills directory format. The machine-level Backpack Engineering
install links only `skills.core` into `~/.agents/skills` and
`~/.claude/skills`. Specialized skills are selected per project from
`skills.tsv` with `backpack find`, `backpack info`, `backpack add`, `backpack remove`, and `backpack list`.
Hosts advertise installed project skill metadata and load a body only when the
request matches.

This split is intentional: Backpack owns the delivery workflow and a minimal
universal core; installed skills provide specialized execution guidance.
Host-native orchestration remains host-owned: Super injects its current `sc`
contract when app-managed orchestration is explicitly requested. A skill is not
activated because it exists in the catalogue, only because it is installed in
the project and the task matches its description.

## Host adapters

All host-specific payloads live under `engineering/adapters/<host>/`. An adapter may
contain a full local configuration template, a small set of subagents, or only
the installation mapping when the host directly consumes the portable files.

| Host | CLI/Desktop coverage | Shared guidance | Backpack Engineering core | Adapter-only concerns |
|---|---|---|---|---|
| Codex | Same portable files in CLI and desktop app | `~/.codex/AGENTS.md` | `~/.agents/skills` | read-only Review/QA agents; personal models, plugins, MCP |
| OpenCode | Same configuration in CLI, TUI, desktop app, and GitHub Action | `~/.config/opencode/AGENTS.md` | `~/.agents/skills` | agents, commands, permissions, provider/model |
| Claude Code | CLI and Desktop Code tab share local configuration | `~/.claude/rules/backpack.md` | `~/.claude/skills` | subagents, hooks, permissions, provider/model |
| Other compatible hosts | Varies by host | global or repo `AGENTS.md` | `.agents/skills` | host permissions and UI |

GitHub Copilot is not a Backpack host. Its workflow and every Copilot-specific
instruction, plugin, hook, and skill remain client-owned. Backpack does not
install or update `~/.copilot`. If Copilot discovers a Backpack skill through
the shared `~/.agents/skills` compatibility path, the skill metadata disables
it for that host.

OpenCode keeps richer phase switching because its primary-agent model makes it
useful. Those modes are an interface over the common workflow, not a second
source of doctrine.

All compatible hosts expose portable skills as the single public surface for
shared capabilities. They do not add aliases such as `/validate` or duplicate
wrapper agents around `backpack-validate`, `backpack-learn`,
`backpack-start-work`, `backpack-pattern-scan`, `backpack-pattern-capture`, or `backpack-enhance-prompt`.
The Codex adapter adds only the two read-only agents that
make Code Review and Product QA independently inspectable in the native subagent
UI. Plan and Build continue to use Codex's native mode and conversation instead
of duplicating host controls.

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
  filter, not a second instruction corpus: Claude Code and OpenCode rewrite
  compatible commands automatically, while Codex inherits the portable shell
  rule. Backpack does not configure Copilot hooks.
- Use `backpack install engineering --all-hosts` to activate the shared workflow for
  Codex, OpenCode, and Claude Code, and merge portable Super preferences. Copilot
  remains untouched.

## Prompt enhancement

`backpack-enhance-prompt` is a hybrid automatic preflight for long, ambiguous,
conflicting, or repetitive prompts. Clear actionable prompts bypass it.
Meaning-preserving cleanup can flow directly into execution without adding a
conversation turn. If a rewrite could change intent, scope, requirements,
acceptance criteria, or permissions, Backpack Engineering preserves the original, shows the
proposal and changes, then waits for explicit validation. An explicit
`backpack-enhance-prompt` invocation always uses this review path. Safe mode preserves detail by default;
compact mode is opt-in.

The agent-level preflight does not guarantee token savings because the original
message remains in model context and the skill itself adds instructions. Its
value is measured across the whole task: fewer retries and clarification turns,
better output relevance, latency, and total input/output tokens. The bypass gate
prevents short clear prompts from paying this overhead.

This is not measured prompt optimization. Calling a prompt “optimized” requires
representative cases, explicit success criteria, and comparative evaluation.
Every host uses the shared `backpack-enhance-prompt` skill directly; no adapter adds a
second shortcut for it.

## Visible execution context

Backpack Engineering does not expose private model reasoning. For non-trivial work it emits
a short public status before acting, then announces any selected skill, subagent,
plugin, or integration when it is actually activated. This is a portable
semantic event: use the host's native rendering when available, otherwise fall
back to a compact line: `[Backpack - <phase>] · <action>` for phase status, then
`[Backpack - <phase>] · [<capability>] <name>` for an activation. The
repeated phase keeps each capability attached to the work that caused it, while
the bracketed label stays easy to scan. Never show both native and fallback
rendering for the same activation. This is an audit trail of the workflow, not a
transcript of every command or internal thought.

Hosts with a dedicated progress surface show it there; other hosts send the same
status in the conversation.

## Delivery loop

```txt
Plan -> Build -> Validate -> Learn
                  /      \
        Code Review      Product QA
```

This lifecycle sits above host modes: discussion and design can contribute to
Plan, implementation happens in Build, Code Review and Product QA supply
Validate, and knowledge codification supplies Learn. Small explicit changes can compress the loop into
inspection, one safe change, targeted validation, and a short handoff. Planning
and validation depth scale with uncertainty, evidence count, blast radius, and
risk.

For ambiguous, multi-source, integration-heavy, or high-risk features, Plan
creates a task-local delivery ledger before edits: requirements and their
sources, explicit versus assumed status, frontend/backend/external ownership,
expected proof, and recorded decisions. Product QA closes that ledger criterion by
criterion. The ledger stays conversational by default so Backpack does not
pollute client repositories with personal process artifacts.

Build inspects project patterns and design-system primitives before changing UI,
uses the installed Impeccable skill for UX/UI work, uses faithful and
discriminating mocks, and favors narrow tests during
iteration. A proportionate broad suite runs once at the end of the delivery
slice. Impeccable's audit or polish pass complements, but never replaces,
browser evidence, Code Review, or Product QA.

Validate reports `READY TO SHIP` only when Code Review approves and Product QA
passes. RTS is not permission to commit or push: Backpack Engineering stops with the evidence,
risk, and Git state until the user explicitly authorizes the exact Git action.

Learn is optional at RTS and may run before or after Git delivery. It reflects,
extracts, and codifies only evidenced reusable knowledge. Project truth stays in
the project, personal patterns stay in personal memory, and a measured workflow
failure may update the smallest effective Backpack enforcement point without
copying doctrine into every host adapter.

## Installation

```sh
# shared workflow
backpack install engineering --all-hosts

# one adapter only
backpack install engineering --codex
backpack install engineering --claude
backpack install engineering --opencode
backpack install engineering --super
```

The installer replaces every selected Backpack-managed path from its canonical
source, so edits in Backpack become visible after starting a new host session.
OpenCode is copied as one full adapter; other hosts use canonical links. Every
replaced local path is moved into a recovery backup first.

## Boundaries

- Project truth stays in each project's `AGENTS.md`, README, docs, and tests.
- Client providers, endpoints, policies, secrets, and tokens stay local.
- Client-owned Copilot configuration stays outside Backpack.
- Personal pattern captures stay outside client repositories.
- Add a host adapter only when the host cannot consume the common standards.
- Use plugins for external capabilities or independently maintained workflows,
  not as the default distribution mechanism for personal instructions.

## Vendored third-party skills

Some curated skills remain vendored from Vercel's official collection because
their performance and composition rules are factual, measurable, and useful
offline. They are no longer installed globally; `backpack add` exposes them only to a
project that needs them:

| Skill | Upstream | Licence |
|---|---|---|
| `vercel-react-best-practices` | `vercel-labs/agent-skills` · `skills/react-best-practices` | MIT |
| `vercel-composition-patterns` | `vercel-labs/agent-skills` · `skills/composition-patterns` | MIT |

Rules for vendored skills:

- Pin the upstream commit in the skill's own `SKILL.md` provenance section, so a
  refresh is a reviewable diff rather than a silent drift.
- Do not vendor an upstream `AGENTS.md` compiled bundle. It duplicates the whole
  `rules/` directory in one always-expanded document and defeats progressive
  disclosure; the per-rule files are the payload.
- Do not edit rule bodies locally. Fix upstream, or add the local delta to
  `AGENTS.md` doctrine instead, so refreshes stay lossless.
- Vendor a skill only when the domain has a credible upstream maintainer.
  Architecture doctrine — boundaries, ports and adapters, dependency direction —
  has none, because no vendor owns that surface. Write those here instead.
- `backpack add` is the supported installation boundary. It delegates project-folder
wiring to the upstream Skills CLI while preserving Backpack's curated skill
  names and limits.

## Compound Engineering decision

Compound Engineering is useful as an off-the-shelf, batteries-included workflow,
but its core plan/build/review/learn loop overlaps this personal workflow and its
large skill catalog adds always-visible metadata. It is therefore not part of the
default installation. Reinstall a focused capability only if a concrete need is
not covered here, such as a team-standard PR operation or an external service.
