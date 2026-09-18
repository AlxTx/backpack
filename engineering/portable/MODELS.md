# Model routing

The workflow uses three semantic tiers so host adapters can change providers or
model families without rewriting the engineering contract.

| Workflow outcome | Tier | OpenAI starting model | Reasoning baseline |
|---|---|---|---|
| Discuss, scope, routine diagnosis | Balanced | `gpt-5.6-terra` | `medium` |
| Plan uncertain or structural work | Frontier | `gpt-5.6-sol` | `high` |
| Hardest cross-system plan or consequential migration | Maximum | `gpt-6-astra` | `high` |
| Product/content/UX design judgment | Frontier | `gpt-5.6-sol` | `high` |
| Implement an approved, well-specified change | Balanced | `gpt-5.6-terra` | `medium` |
| Review correctness or meaningful regression risk | Frontier | `gpt-5.6-sol` | `high` |
| Security-sensitive review or exceptionally costly error | Maximum | `gpt-6-astra` | `high` or `xhigh` |
| Consolidate Code Review and Product QA | Balanced | `gpt-5.6-terra` | `medium` |
| Product QA or knowledge codification | Balanced | `gpt-5.6-terra` | `medium` |
| Pattern scan / unfamiliar-code orientation | Balanced | `gpt-5.6-terra` | `medium` |
| Classification, extraction, routing, routine automation | Balanced | `gpt-5.6-terra` | `low` or `medium` |

These are starting points, not permanent truths. Preserve explicit user choices
and validate representative work before lowering or raising reasoning effort.
Use `xhigh` or `max` only when a quality-first evaluation shows a meaningful
gain; do not make them global defaults.

## Host mapping

- **OpenCode** deliberately leaves every primary agent and subagent unpinned.
  The model selected in the current session is therefore inherited through
  Plan, Build, Validate, Code Review, Product QA, Learn, design, exploration,
  and pattern scanning. The semantic tiers above remain recommendations for a
  deliberate session-level switch, never hidden provider routing.
- **Codex** uses Terra/medium as the recommended everyday thread default. Select
  Sol/high for planning or review threads, Astra/high for the hardest end-to-end
  or consequential work, and keep Terra for a thread executing a settled plan.
- **Other hosts** should map Maximum, Frontier, and Balanced to their available
  provider tiers while preserving the role and validation bar. Two tiers may
  share a model when the host exposes fewer useful choices.

## Why this routing

OpenAI recommends Astra for the hardest end-to-end work, describes Sol as the
GPT-5.6 flagship for complex professional work, and positions Terra as the
balanced everyday tier. Backpack Engineering deliberately stops at Terra because this is an
interactive professional workflow without an established high-volume workload;
the simpler three-model choice is worth more than an additional lower tier.
Introduce one only after representative automation volume shows a material
benefit. Maximum remains an explicit escalation rather than a default.

Revisit this file when models, prices, quotas, or measured task quality change.
Do not put client-specific providers, endpoints, or credentials here.

## Official references

- [GPT-5.6 price/performance guidance](https://openai.com/index/advancing-the-price-performance-frontier-with-gpt-5-6/)
- [GPT-5.6 model and prompting guidance](https://developers.openai.com/api/docs/guides/latest-model?model=gpt-5.6)
- [GPT-6 Astra announcement](https://openai.com/index/gpt-6-astra/)
- [GPT-6 Astra model reference](https://developers.openai.com/api/docs/models/gpt-6-astra)
