---
name: cockpit-validate
description: Validate a completed delivery slice by running independent read-only Code Review and Product QA, then consolidate delivery readiness. Use for final validation or Ready-to-Ship checks; not for routine tests during implementation.
---

# Cockpit Validate

Preserve the active requirements, decisions, expected proof, and diff scope. Do
not reinterpret the delivery contract or widen the work.

Run two independent read-only lenses concurrently when the host supports
subagents: Cockpit Code Review checks whether the solution is correctly built,
and Cockpit Product QA checks whether the right product was built.

Use the host's dedicated Code Review and Product QA agents when available.
Otherwise delegate the same two bounded contracts to separate general-purpose
subagents. Wait for both results and keep
their evidence and verdicts separate. If independent delegation is unavailable,
report `DEPENDENCY PENDING`. A sequential audit may still provide diagnostic
evidence, but it cannot satisfy the delivery gate or produce `READY TO SHIP`.

Do not edit files or perform Git delivery actions. Missing requirements,
credentials, fixtures, browser access, or external evidence produce
`DEPENDENCY PENDING`, not an inferred pass.

Consolidate the result:

- `READY TO SHIP` only when Code Review is `APPROVE` and Product QA is `PASS`;
- `CHANGES REQUIRED` when either lens finds an in-scope defect;
- `DEPENDENCY PENDING` when required proof or external work is unavailable.

Return the status first, then the two verdicts with material evidence, residual
risk, manual-acceptance recommendation, diff scope, and Git state. End by stating
that no commit, push, merge, pull request, or deployment was performed.
