# Cockpit routing

## Daily flow

1. **Model preflight** — Cockpit classifies the task before substantive work. If
   the active model is known and another tier is materially safer or safely
   cheaper, it explains why and states who must perform the switch. On a manual
   host, change the model in its selector, then answer `yes` once it is active;
   answer `no` to keep the current model. Cockpit does not ask for a second
   confirmation.
2. **Plan** — stay in Build for proportional planning, select the read-only Plan
   agent with `Tab`, or use `/cockpit-brainstorm` for divergent exploration.
3. **Build** — select Build with `Tab`, then ask naturally for the approved
   implementation. `/cockpit-design` can first isolate a content/UX/UI contract.
4. **Validate** — invoke `cockpit-validate` for independent Code Review and
   Product QA. Use `/cockpit-review` or `/cockpit-qa` only when one lens is wanted.
5. **Learn** — invoke `cockpit-learn` when a completed slice has reusable lessons.
6. **Git** — wait for an exact `commit`, `push`, or `commit and push` instruction.
   `READY TO SHIP` alone never authorizes delivery.

The OpenAI mapping is intentionally limited to three choices:

| Tier | Model | Use |
|---|---|---|
| Balanced | Terra | everyday work, settled implementation, routine validation |
| Frontier | Sol | uncertain planning, complex work, risky review |
| Maximum | Astra | hardest end-to-end work, security, consequential migrations |

When the current model is not reliably available to the agent, Cockpit does not
invent a mismatch or block the task. Model changes use the host's native selector
and preserve the user's explicit choice.

Example on a host with manual model selection:

```txt
Cockpit › build · Terra/medium is sufficient instead of Sol/high for this bounded
documentation change. Switch manually in the model selector, then reply yes once
it is active; reply no to continue with Sol/high.
```

## Controls and surfaces

Mental model:

- `Tab` changes the current primary agent: build or plan.
- `/command` runs a host-only prepared action; shared capabilities remain skills.
- A pinned command uses its declared agent and does not depend on the current mode.
- A subagent is an isolated specialist used for one task.
- OpenCode `auto` changes permission approval only; it is not an agent or phase.

Current cockpit:

```txt
Build       -> default work: discuss, diagnose, plan proportionally, implement, validate
Plan        -> sustained read-only planning with edits and shell denied
Brainstorm  -> /cockpit-brainstorm runs a divergent read-only recipe through Plan
Design      -> /cockpit-design delegates an isolated product-design contract
Validate    -> cockpit-validate runs Code Review + Product QA in read-only mode
Learn       -> cockpit-learn reflects, extracts, and routes reusable knowledge
```

These controls implement one delivery lifecycle rather than separate competing
workflows:

```txt
Plan     -> explicit primary posture, or /cockpit-brainstorm for divergent exploration
Build    -> default agent with automatic skill/subagent routing
Validate -> cockpit-validate -> independent Code Review + Product QA -> RTS status
Learn    -> cockpit-learn; cockpit-pattern-capture remains the persistence primitive
```

On OpenCode, `/cockpit-review` and `/cockpit-qa` also deny shell so their
read-only boundary is technically enforceable. They review the supplied delivery
context and report missing executable or rendered proof as `DEPENDENCY PENDING`.
Other hosts may allow non-mutating inspection commands within their native
read-only sandbox or permission mode.

`/cockpit-review` and `/cockpit-qa` remain independently callable on hosts that
expose those host-only lens commands. `cockpit-validate` is the default
delivery gate and reports `READY TO SHIP`, `CHANGES REQUIRED`, or
`DEPENDENCY PENDING`. RTS never commits or pushes; it waits for an explicit Git
instruction. `cockpit-learn` is optional at RTS and does not modify the product by
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

Backpack provides the portable cockpit core. The updater replaces the complete
OpenCode adapter from `cockpit/adapters/opencode/`. The adapter deliberately
leaves models unpinned, so provider/model choices stay in the user's host profile
or session, with secrets kept outside Backpack.
The current OpenAI routing is documented in `cockpit/portable/MODELS.md`: Astra
for the hardest or most consequential work, Sol for uncertainty and high-risk
review, and Terra for balanced work, settled implementation, and routine
execution. Before substantive work, Cockpit recommends a safer upgrade or a
risk-free cheaper downgrade when the current model is known, then waits for an
explicit yes/no decision.

All Backpack-owned Cockpit skills and OpenCode slash commands use the
`cockpit-` prefix across hosts.

Future guardrail idea: show active agent permission badges in OpenCode UI, e.g.
`NO-IO`, `READ · SH?`, or `WRITE · SH?`. See
[`opencode-permission-badges.md`](opencode-permission-badges.md).

Future progress UX: render Cockpit phase, current activity, and optional active
skill as a compact terminal-style status block. See
[`cockpit-progress-surface.md`](cockpit-progress-surface.md).
