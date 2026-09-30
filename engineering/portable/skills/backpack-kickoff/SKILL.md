---
name: backpack-kickoff
description: Start or resume a substantial project or product change with interactive greenfield or brownfield framing, one question at a time. Use when the user asks for a kickoff or to resume project framing. In GitHub Copilot, do not use this skill; follow the client-owned workflow instead.
---

# Backpack Kickoff

Start from the current conversation, briefs, decisions, artifacts, and delivered
work. For an initiative already underway, reconstruct its current state instead
of restarting Discovery. If it is unclear whether the work starts from scratch
or changes an existing product, ask one plain-language greenfield/brownfield
question and wait for the answer.

For greenfield work, establish the problem, intended users, desired outcome,
essential journeys, and first deliverable as needed. For brownfield work,
inspect the relevant existing product or codebase, then define the requested
change and what behavior must remain intact. Explore UX, technical design, and
planning only where they affect the next decision.

On each turn, briefly state what is established and what remains open. Use
`🧭 Kickoff` for the visible activity; name project-framing milestones such as
Discovery or Product Definition only when they help explain the current state.
If the user wants a visual plan, show a short Markdown checklist for the current slice or
milestone. Distinguish Discovery, Definition (requirements and UX), Engineering
(technical design and plan), and Delivery (Build and proof) where applicable.
Show the move into Engineering only when the current slice has enough product
and UX direction to make technical choices. This project view is separate from
the five-step activity status. Check an item only when its decision or deliverable
has evidence;
label unchecked items In progress or Pending and name the next decision. Keep a
completed first slice distinct from unfinished product-wide work. Link to
existing artifacts rather than duplicating their contents. Revisit the checklist
when new evidence changes a status.

Ask the single most useful unresolved question and wait for the user's answer
before continuing. Do not present the whole phase sequence as a questionnaire
or claim a phase is complete without supporting evidence. When no material
question remains, propose the first coherent delivery slice and its expected
proof.

This kickoff is read-only. Keep the checklist in the conversation. A project-owned
Markdown tracker is optional and can be created or updated during an authorized
Build request. Do not edit files, start Build, or perform Git delivery actions
as part of this skill.
