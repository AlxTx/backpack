---
name: backpack-learn
description: Extract evidenced, reusable lessons from completed work. In GitHub Copilot, do not use this skill; follow the client-owned workflow instead.
---

# Backpack Learn

Inspect the completed slice in read-only mode and assess both the delivered
result and the process used to reach it. Extract only lessons supported by the
conversation, diff, validation evidence, or an established repeated outcome.

Route each useful lesson deliberately:

- project-specific truth → the project's conventional documentation;
- reusable personal software pattern → describe the evidence and propose a
  durable destination for a separate authorized change;
- measured cross-project workflow lesson → a proposed Backpack Engineering improvement at
  the smallest effective enforcement point;
- one-off observation → discard.

For a repeated or consequential agent failure, first check whether an existing
rule, skill, adapter, or executable check already addresses it. If a Backpack
change is still warranted, return one compact failure case: the triggering
task, observed and expected behavior, evidence, smallest proposed control, and
the same scenario or signal that would demonstrate improvement. Prefer a fast
executable check when the failure has an objective condition; use instructions
for judgment or context that cannot be checked mechanically. Keep host-specific
behavior in its adapter. Report the outcome as unverified until the control has
been applied and observed on the case.

Do not edit the product, project documentation, or Backpack Engineering during Learn. Any
proposed documentation, rule, skill, check, or template change starts a separate
Build → Validate slice.

Return the outcome assessment, process assessment, proposed durable destinations,
and at most one worthwhile follow-up slice.
