---
description: Run Product QA against the requested behavior and delivery contract.
agent: qa
subtask: false
---

Validate the product behavior for this scope: $ARGUMENTS

If no scope is given, use the active delivery slice and its requirements. Shell
is denied to keep the audit strictly read-only; report unavailable evidence as
`DEPENDENCY PENDING`. Return the Product QA verdict.
