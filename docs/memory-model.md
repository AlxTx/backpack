# Memory model

Three separate memory locations:

1. `backpack/memory` — durable personal knowledge: craft, AI, concepts, books, playbooks.
2. Client vault — operational mission memory, local/client-only, outside backpack.
3. Project repo docs — shared project truth: `README.md`, `AGENTS.md`, `docs/`, ADRs.

Rules:

- Never put client notes in backpack.
- Never load a whole memory tree into an LLM context.
- Read an index first, then only the 1–3 relevant notes.
- Promote only anonymized reusable lessons from client work to backpack.
