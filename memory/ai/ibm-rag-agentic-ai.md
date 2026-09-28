# IBM RAG and Agentic AI — durable notes

Source: personal notes from the IBM RAG and Agentic AI Professional Certificate,
completed 2026-09-27. This is a compact decision map from those notes, not a
reference for current framework APIs.

## Architecture choices

| Need | First candidate |
|---|---|
| Bounded generation | Direct model call |
| Predictable multi-step transformation | Defined workflow |
| Private or changing knowledge | Retrieval-augmented generation |
| External action or deterministic calculation | Validated tool call |
| Dynamic choice among actions | Agent with a bounded execution loop |
| Explicit state, branches, retries, or pause/resume | Graph workflow |
| Independent specialist responsibilities | Multi-agent coordination |
| Shared capability discovery across applications | MCP |

Advance only when representative failures justify the added complexity.

## RAG and retrieval

Index sources into retrievable units, then retrieve candidate text and give the
selected source content to the generation model. Embeddings represent content;
retrieval selects it; the model generates an answer. Keep document and query
vectors in compatible spaces, source IDs attached, and the knowledge base
current. Evaluate retrieval separately from generated answers.

Choose retrieval changes by failure: lexical search for exact identifiers,
metadata filters for structured constraints, MMR for redundant results, query
rewriting for wording sensitivity, parent context for fragmented passages, and
reranking when good candidates are ordered poorly. Compare those changes with
a simple baseline on representative questions. Distinct modality scores need
calibration before fusion.

## Tools, agents, and MCP

A model proposes a tool call; the runtime validates and executes it. Structured
schemas, least privilege, bounded loops, observability, and explicit failure
paths make that boundary controllable. A single agent and a multi-agent system
have different coordination costs; specialized agents need clear inputs,
outputs, ownership, and handoffs.

MCP standardizes access to tools, resources, and prompts across a host, client,
transport, and server. Tool execution, filesystem scope, sampling, and user
input remain governed by the host/application. MCP connectivity and
conversation memory are separate concerns.

## Verification boundary

The course examples name LangChain, LangGraph, LlamaIndex, CrewAI, AG2, BeeAI,
FastMCP, Chroma, FAISS, and Milvus. Their APIs, defaults, and deployment options
can change. Use the notes for mental models; check installed versions and
official documentation for implementation details. Treat course quiz rules as
course-specific unless project evidence supports a broader rule.
