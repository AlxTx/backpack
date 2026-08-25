# Model routing

The workflow uses three semantic tiers so host adapters can change providers or
model families without rewriting the engineering contract.

| Workflow outcome | Tier | GPT-5.6 starting model | Reasoning baseline |
|---|---|---|---|
| Discuss, scope, routine diagnosis | Balanced | `gpt-5.6-terra` | `medium` |
| Plan uncertain or structural work | Frontier | `gpt-5.6-sol` | `high` |
| Product/content/UX design judgment | Frontier | `gpt-5.6-sol` | `high` |
| Implement an approved, well-specified change | Fast | `gpt-5.6-luna` | `medium` |
| Review correctness or meaningful regression risk | Frontier | `gpt-5.6-sol` | `high` |
| Consolidate Code Review and Product QA | Frontier | `gpt-5.6-sol` | `high` |
| Product QA or knowledge codification | Balanced | `gpt-5.6-terra` | `medium` |
| Pattern scan / unfamiliar-code orientation | Balanced | `gpt-5.6-terra` | `medium` |
| Classification, extraction, routing, background automation | Fast | `gpt-5.6-luna` | `low` or `medium` |

These are starting points, not permanent truths. Preserve explicit user choices
and validate representative work before lowering or raising reasoning effort.
Use `xhigh` or `max` only when a quality-first evaluation shows a meaningful
gain; do not make them global defaults.

## Host mapping

- **OpenCode** maps each primary agent to a concrete model in
  `cockpit/adapters/opencode/opencode.json`.
- **Codex** uses Terra/medium as the recommended everyday thread default. Select
  Sol/high for planning or review threads and Luna/medium for a thread executing
  a settled plan when latency or quota matters.
- **Other hosts** should map Frontier, Balanced, and Fast to their available
  provider tiers while preserving the role and validation bar.

## Why this routing

OpenAI's GPT-5.6 price/performance guidance recommends matching intelligence to
the stakes, cost of error, urgency, and scale. Its coding example uses Sol to
resolve uncertainty and define a plan, then Luna for well-specified
implementation, tests, and evaluation. Terra is the balanced everyday tier.

Revisit this file when models, prices, quotas, or measured task quality change.
Do not put client-specific providers, endpoints, or credentials here.

## Official references

- [GPT-5.6 price/performance guidance](https://openai.com/index/advancing-the-price-performance-frontier-with-gpt-5-6/)
- [GPT-5.6 model and prompting guidance](https://developers.openai.com/api/docs/guides/latest-model?model=gpt-5.6)
