# Cockpit routing

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
Brainstorm  -> /brainstorm runs a divergent read-only recipe through Plan
Design      -> /design delegates an isolated product-design contract
Validate    -> cockpit-validate runs Code Review + Product QA in read-only mode
Learn       -> cockpit-learn reflects, extracts, and routes reusable knowledge
```

These controls implement one delivery lifecycle rather than separate competing
workflows:

```txt
Plan     -> explicit primary posture, or /brainstorm for divergent exploration
Build    -> default agent with automatic skill/subagent routing
Validate -> cockpit-validate -> independent Code Review + Product QA -> RTS status
Learn    -> cockpit-learn; pattern-capture remains the persistence primitive
```

`/review` and `/qa` remain independently callable on hosts that expose those
host-only lens commands. `cockpit-validate` is the default
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
OpenCode adapter from `cockpit/adapters/opencode/`; provider/model choices that
must persist belong in that canonical config, with secrets kept outside it.
The current GPT-5.6 routing is documented in `cockpit/portable/MODELS.md`: Terra
for balanced work, Sol for uncertainty and high-risk review, Luna for settled
implementation and routine execution.

Future guardrail idea: show active agent permission badges in OpenCode UI, e.g.
`NO-IO`, `READ · SH?`, or `WRITE · SH?`. See
[`opencode-permission-badges.md`](opencode-permission-badges.md).

Future progress UX: render Cockpit phase, current activity, and optional active
skill as a compact terminal-style status block. See
[`cockpit-progress-surface.md`](cockpit-progress-surface.md).
