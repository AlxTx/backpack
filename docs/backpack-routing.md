# Backpack Engineering routing

## Daily flow

For a new or ongoing initiative, describe the goal naturally. When it is unclear whether
the work starts from scratch, Backpack asks:

> Are we starting a new project from scratch (greenfield: no established product
> behavior to preserve), or evolving something that exists (brownfield: a
> product, site, API, or codebase already in use)?

Answer in your own words. Backpack skips this question when the context already
answers it. Greenfield work may need discovery, product requirements, journeys,
technical design, and a first delivery slice. Brownfield work starts by
inspecting the existing product and defining the change. Backpack raises only
the next useful question or decision; these activities do not need separate
commands or a fixed set of documents.

Invoke `backpack-kickoff` to start or resume this guided conversation explicitly: choose
the skill in Codex, type `/backpack-kickoff` in Claude Code or OpenCode, or use
`🧭 Kickoff` in Super.

The visible workflow has five flexible steps:

1. **💭 Explore** — discuss, decide, or diagnose in read-only mode. Use
   `/backpack-brainstorm` for divergent options or `backpack-pattern-scan` for
   established codebase patterns when those focused actions help.
2. **📋 Plan** — produce an execution-ready plan when needed. In OpenCode,
   select the read-only Plan agent with `Tab`; `/backpack-design` can isolate a
   content/UX/UI contract.
3. **🛠️ Build** — request the approved implementation. In Super, the optional
   `👥 Team build` command asks for visible app-managed coordination when useful.
4. **⚖️ Validate** — invoke `backpack-validate` for independent Code Review and
   Product QA. Use `/backpack-review` or `/backpack-qa` only when one lens is wanted.
5. **📚 Learn** — invoke `backpack-learn` when a completed slice has reusable lessons.

`🧭 Kickoff` is a guided entry for a substantial new or ongoing initiative, not
another required step. Diagnose remains a distinct read-only request within
Explore; Team build remains a Build variant. The user does not need to select
every step for a small task.

Before substantive work, Backpack Engineering classifies the task and compares
the active model when the host exposes it. If another tier is materially safer
or safely cheaper, switch manually in the host selector, then answer `yes` once
it is active or `no` to continue. After delivery is ready, Git still waits for
an exact `commit`, `push`, or `commit and push` instruction; `READY TO SHIP`
alone never authorizes it.

For AI application architecture in a project, inspect
`backpack info ai-engineering` and install the optional guidance there with
`backpack add ai-engineering`. It covers LLM, retrieval, tool, agent,
multimodal, and MCP decisions without adding a new global Backpack command.

### Start or resume a project

In Super, open the project's folder and start a provider chat. If a brief
already exists, attach or reference it in a message first. Then choose
`🧭 Kickoff` from the worktree action card or Command Palette.
For a new project, for example:

```text
New project from scratch: TheTokenSide. Use TheTokenSide.md as the brief.
```

Backpack reads the available context, asks only the next useful question, and
waits for your answer in that same chat. Continue until it identifies the first
coherent delivery slice and how to prove it works. Ask for Build separately;
kickoff itself stays read-only. For a feature in an existing product, use the
same command: Backpack follows the brownfield path.

For work already underway, use the same command and give the current brief,
decisions, and delivered work. For example:

```text
Resume this project from its current state. Read the brief, decisions, and work
already done. Show a checklist for the current slice with Done, In progress, or
Pending and evidence for each status. Ask only the next material question.
```

The checklist can appear directly in chat:

```md
## Current slice: RAG page

### Discovery ✓
- [x] Problem, audience, outcome — `brief.md`

### Definition - In progress
- [x] Requirements — `requirements.md`: first-slice acceptance criteria
- [ ] UX / Information Architecture — page flow outlined; states open

### Engineering - Pending
- [ ] Technical Design — RAG architecture decision open
- [ ] Planning — first build tasks and proof still to define

### Delivery - Pending
- [ ] Build — first slice not started
- [ ] Validate — acceptance proof not yet collected
```

These are illustrative statuses, not claims about an actual project. Check a box
only when the relevant decision or deliverable has supporting evidence. Keep
slice-level progress separate from unfinished product-wide scope. For a durable
view across chats, ask Backpack to create or update one Markdown tracker in the
project during Build; kickoff only shows the view in chat. Later Build work keeps
an opted-in tracker aligned with evidenced progress.
Move the current slice into Engineering once its requirements and essential
journey are clear enough to make the necessary technical choices. The project
view describes maturity of the slice; `💭 Explore` through `📚 Learn` describes
what Backpack is doing now.

Without Super, select `backpack-kickoff` in Codex's skill picker, type
`/backpack-kickoff` in Claude Code or OpenCode, or describe the initiative in
ordinary language. Refresh the provider adapter after updating Backpack so
the new entrypoint appears in a new chat.

The OpenAI mapping is intentionally limited to three choices:

| Tier | Model | Use |
|---|---|---|
| Balanced | Terra | everyday work, settled implementation, routine validation |
| Frontier | Sol | uncertain planning, complex work, risky review |
| Maximum | Astra | hardest end-to-end work, security, consequential migrations |

When the current model is not reliably available to the agent, Backpack Engineering does not
invent a mismatch or block the task. Model changes use the host's native selector
and preserve the user's explicit choice.

Example on a host with manual model selection:

```txt
🛠️ Build - Model choice
```

Terra/medium is sufficient instead of Sol/high for this bounded documentation
change. Switch manually in the model selector, then reply yes once it is active;
reply no to continue with Sol/high.

## Controls and surfaces

Mental model:

- `Tab` changes the current primary agent: build or plan.
- `/command` runs a named OpenCode action. Shared workflows load portable skills.
- A pinned command uses its declared agent and does not depend on the current mode.
- A subagent is an isolated specialist used for one task.
- OpenCode `auto` changes permission approval only; it is not an agent or phase.

Current engineering:

```txt
Explore     -> discuss or diagnose in read-only mode; Brainstorm and Pattern scan are focused actions
Plan        -> sustained read-only planning with edits and shell denied
Build       -> default implementation; Team build is an optional orchestration variant
Validate    -> backpack-validate runs Code Review + Product QA in read-only mode
Learn       -> backpack-learn reflects, extracts, and routes reusable knowledge
```

These controls implement one delivery lifecycle rather than separate competing
workflows:

```txt
Explore  -> natural conversation; /backpack-brainstorm or backpack-pattern-scan when useful
Plan     -> explicit primary posture; /backpack-design can isolate a design contract
Build    -> default agent with automatic skill/subagent routing
Validate -> backpack-validate -> independent Code Review + Product QA -> RTS status
Learn    -> backpack-learn proposes durable knowledge for a separate change
```

On OpenCode, `/backpack-review` and `/backpack-qa` also deny shell so their
read-only boundary is technically enforceable. They review the supplied delivery
context. Missing executable or rendered proof is `DEPENDENCY PENDING` when a
material criterion needs it and no trustworthy alternative is available.
Other hosts may allow non-mutating inspection commands within their native
read-only sandbox or permission mode.

Validate can still run when the application cannot be launched locally. Product
QA checks each criterion against available contracts, diffs, CI results,
previews, screenshots, and logs, then names the exact behavior that remains
unverified. A static change can pass on sufficient static proof; an untested
material interaction stays pending with a focused manual-acceptance or preview
step. Lack of local access by itself is not a Product QA failure.

`/backpack-review` and `/backpack-qa` remain independently callable on hosts that
expose those host-only lens commands. `backpack-validate` is the default
delivery gate and reports `READY TO SHIP`, `CHANGES REQUIRED`, or
`DEPENDENCY PENDING`. RTS never commits or pushes; it waits for an explicit Git
instruction. `backpack-learn` is optional at RTS and does not modify the product by
default.

For uncertain or integration-heavy features, Plan also maintains a task-local
requirements/decisions ledger. It separates frontend-deliverable work, backend
or external evidence still needed, and out-of-scope items. Small explicit work
does not need this extra artifact.

The lifecycle stays stable across contexts, while phase behavior changes:

- BROWNFIELD preserves established contracts and regression surfaces.
- GREENFIELD establishes the smallest coherent product, design, and technical
  contract for a vertical slice.
- SOLO work accepts narrow reversible defaults without fake stakeholder
  ceremony; TEAM and CLIENT work retain shared decisions and approval boundaries.

Backpack provides the portable engineering core. The updater replaces the complete
OpenCode adapter from `engineering/adapters/opencode/`. The adapter deliberately
leaves models unpinned, so provider/model choices stay in the user's host profile
or session, with secrets kept outside Backpack.
The current OpenAI routing is documented in `engineering/portable/MODELS.md`: Astra
for the hardest or most consequential work, Sol for uncertainty and high-risk
review, and Terra for balanced work, settled implementation, and routine
execution. Before substantive work, Backpack Engineering recommends a safer upgrade or a
risk-free cheaper downgrade when the current model is known, then waits for an
explicit yes/no decision.

All Backpack Engineering skills and OpenCode slash commands use the
`backpack-` prefix across hosts.

Future guardrail idea: show active agent permission badges in OpenCode UI, e.g.
`NO-IO`, `READ · SH?`, or `WRITE · SH?`. See
[`opencode-permission-badges.md`](opencode-permission-badges.md).

Future progress UX: render Backpack Engineering phase, current activity, and optional active
skill as a compact terminal-style status block. See
[`backpack-progress-surface.md`](backpack-progress-surface.md).
