---
name: ai-engineering
description: Design or assess an LLM application that uses retrieval, tools, agents, multimodal inputs, or MCP. Use for architecture and evaluation choices, not routine SDK syntax.
---

# AI Engineering

Use this project skill only for the AI system decisions in scope. Follow the
project's contracts and Backpack's normal Plan, Build, and Validate workflow;
this skill adds no delivery phase, Git permission, or generic agent command.

Start with the user task, available data, failure cost, and representative
success cases. Choose the least complex architecture that can meet them: a
direct model call, a defined workflow, retrieval, tool use, or dynamic agent
control. Add state, loops, or multiple agents only when the required behavior
needs them. Make model choice against quality, latency, cost, privacy, and
deployment constraints on the same representative cases.

When retrieval is relevant, distinguish indexing, candidate retrieval,
ranking, and answer generation. Establish a simple baseline and inspect its
failures before adding query rewriting, lexical and semantic fusion, metadata
filters, parent context, reranking, corrective loops, or multimodal fusion.
Keep document and query embeddings compatible. Preserve source identifiers and
test both retrieval relevance and answer grounding; a plausible answer alone
does not prove the right evidence was found.

For tool-using systems, keep execution in the application runtime. Validate
structured arguments, permissions, and results before acting; bound retries,
tool calls, and cost. Prefer deterministic software for calculations and
business rules. When MCP is involved, separate host, client, transport, and
server responsibilities, and expose only the capabilities and data scope the
application needs.

Evaluate the actual user journey on representative normal, ambiguous,
outdated, and failure cases. Report answer quality and source fidelity alongside
latency, cost, and operational failures. Keep framework and protocol API details
version-specific: inspect the installed versions and current official
documentation before implementing them.
