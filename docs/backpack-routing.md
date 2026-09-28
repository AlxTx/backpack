# Backpack Engineering routing

## Daily flow

For a new initiative, describe the goal naturally. When it is unclear whether
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

Invoke `backpack-kickoff` to start this guided conversation explicitly: choose
the skill in Codex, type `/backpack-kickoff` in Claude Code or OpenCode, or use
`Backpack · Project kickoff` in Super.

1. **Model preflight** — Backpack Engineering classifies the task before substantive work. If
   the active model is known and another tier is materially safer or safely
   cheaper, it explains why and states who must perform the switch. On a manual
   host, change the model in its selector, then answer `yes` once it is active;
   answer `no` to keep the current model. Backpack Engineering does not ask for a second
   confirmation.
2. **Plan** — stay in Build for proportional planning, select the read-only Plan
   agent with `Tab`, or use `/backpack-brainstorm` for divergent exploration.
3. **Build** — select Build with `Tab`, then ask naturally for the approved
   implementation. `/backpack-design` can first isolate a content/UX/UI contract.
4. **Validate** — invoke `backpack-validate` for independent Code Review and
   Product QA. Use `/backpack-review` or `/backpack-qa` only when one lens is wanted.
5. **Learn** — invoke `backpack-learn` when a completed slice has reusable lessons.
6. **Git** — wait for an exact `commit`, `push`, or `commit and push` instruction.
   `READY TO SHIP` alone never authorizes delivery.

For AI application architecture in a project, inspect
`backpack info ai-engineering` and install the optional guidance there with
`backpack add ai-engineering`. It covers LLM, retrieval, tool, agent,
multimodal, and MCP decisions without adding a new global Backpack command.

### Start a new project in Super

Open the new project's folder in Super and start a provider chat. If a brief
already exists, attach or reference it in a message first. Then choose
`Backpack · Project kickoff` from the worktree action card or Command Palette.
For example:

```text
New project from scratch: TheTokenSide. Use TheTokenSide.md as the brief.
```

Backpack reads the available context, asks only the next useful question, and
waits for your answer in that same chat. Continue until it identifies the first
coherent delivery slice and how to prove it works. Ask for Build separately;
kickoff itself stays read-only. For a feature in an existing product, use the
same command: Backpack follows the brownfield path.

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
[Backpack - Build] · Terra/medium is sufficient instead of Sol/high for this bounded
documentation change. Switch manually in the model selector, then reply yes once
it is active; reply no to continue with Sol/high.
```

## Controls and surfaces

Mental model:

- `Tab` changes the current primary agent: build or plan.
- `/command` runs a named OpenCode action. Shared workflows load portable skills.
- A pinned command uses its declared agent and does not depend on the current mode.
- A subagent is an isolated specialist used for one task.
- OpenCode `auto` changes permission approval only; it is not an agent or phase.

Current engineering:

```txt
Build       -> default work: discuss, diagnose, plan proportionally, implement, validate
Plan        -> sustained read-only planning with edits and shell denied
Brainstorm  -> /backpack-brainstorm runs a divergent read-only recipe through Plan
Design      -> /backpack-design delegates an isolated product-design contract
Validate    -> backpack-validate runs Code Review + Product QA in read-only mode
Learn       -> backpack-learn reflects, extracts, and routes reusable knowledge
```

These controls implement one delivery lifecycle rather than separate competing
workflows:

```txt
Plan     -> explicit primary posture, or /backpack-brainstorm for divergent exploration
Build    -> default agent with automatic skill/subagent routing
Validate -> backpack-validate -> independent Code Review + Product QA -> RTS status
Learn    -> backpack-learn proposes durable knowledge for a separate change
```

On OpenCode, `/backpack-review` and `/backpack-qa` also deny shell so their
read-only boundary is technically enforceable. They review the supplied delivery
context and report missing executable or rendered proof as `DEPENDENCY PENDING`.
Other hosts may allow non-mutating inspection commands within their native
read-only sandbox or permission mode.

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
